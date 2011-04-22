#==
# Copyright (C) 2011 Pete Favelle; based on work
# Copyright (C) 2008 James S Urquhart
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++

class SearchesController < ApplicationController
  layout :search_layout
  
  # GET /search
  def show
    
    respond_to do |format|
      format.html # show.html.erb
    end

  end

  # POST /search
  def create

    @search = Sunspot.search( Note, Code, ListItem, List, Album, AlbumPicture ) do
      keywords( params[:query] )
    end

    @results = Hash.new

    @search.each_hit_with_result do |hit,obj|

      # check to see if the page is visible to the user
      if @logged_user.nil?
        unless obj.page.is_public
          next
        end
      else
        unless obj.page.can_be_seen_by( @logged_user )
          next
        end
      end

      # figure out the text we'll use to describe it
      case hit.class_name
        when "ListItem"
          objname = obj.list.name
        when "List"
          objname = obj.name
        when "AlbumPicture"
          objname = obj.album.title
        else
          objname = obj.title
      end

      # and add it into the hash
      if @results.include? ( obj.page )
        @results[obj.page] << '; ' << objname 
      else
        @results[obj.page] = objname
      end

    end
    
    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

protected

  def authorized?(action = action_name, resource = nil)
    logged_in? or true
  end

  def search_layout
    return 'pages' if logged_in? 
    return 'public_search' 
  end

end
