Paperclip::Attachment.interpolations[:album_id] = proc do |attachment, style|
  attachment.instance.album_id 
end
Paperclip::Attachment.interpolations[:page_id] = proc do |attachment, style|
  attachment.instance.album.page_id 
end
