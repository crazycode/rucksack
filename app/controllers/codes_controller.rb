#==
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

class CodesController < ApplicationController
  before_filter :grab_page
  
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  
  # GET /codes
  # GET /codes.xml
  def index
    @codes = @page.codes.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @codes }
    end
  end

  # GET /codes/1
  # GET /codes/1.xml
  def show
    @code = @page.codes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @code }
    end
  end

  # GET /codes/new
  # GET /codes/new.xml
  def new
    return error_status(true, :cannot_create_code) unless (Code.can_be_created_by(@logged_user, @page))
    
    @code = @page.codes.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @code }
    end
  end

  # GET /codes/1/edit
  def edit
    @code = @page.codes.find(params[:id])
    return error_status(true, :cannot_edit_code) unless (@code.can_be_edited_by(@logged_user))

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /codes
  # POST /codes.xml
  def create
    return error_status(true, :cannot_create_code) unless (Code.can_be_created_by(@logged_user, @page))
    
    calculate_position
    
    # Make the darn code
    @code = @page.codes.build(params[:code])
    @code.created_by = @logged_user
    saved = @code.save
    
    # And the slot, don't forget the slot
    save_slot(@code) if saved
    
    respond_to do |format|
      if saved
        error_status(false, :success_code_created)
        format.html { redirect_to(@code) }
        format.js {}
        format.xml  { render :xml => @code, :status => :created, :location => page_code_path(:page_id => @page.id, :id => @code.id) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /codes/1
  # PUT /codes/1.xml
  def update
    @code = @page.codes.find(params[:id])
    return error_status(true, :cannot_edit_code) unless (@code.can_be_edited_by(@logged_user))
    
    @code.updated_by = @logged_user

    respond_to do |format|
      if @code.update_attributes(params[:code])
        flash[:notice] = 'Code was successfully updated.'
        format.html { redirect_to(@code) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /codes/1
  # DELETE /codes/1.xml
  def destroy
    @code = @page.codes.find(params[:id])
    return error_status(true, :cannot_delete_code) unless (@code.can_be_deleted_by(@logged_user))
    
    @slot_id = @code.page_slot.id
    @code.page_slot.destroy
    @code.updated_by = @logged_user
    @code.destroy

    respond_to do |format|
      format.html { redirect_to(codes_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
end
