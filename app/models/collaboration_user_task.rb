class CollaborationUserTask < CollaborationUser
# This Class exists only to work around the fact that Rails does not
# honor the :primary_key directive in a :through relationship
# http://stackoverflow.com/questions/2196476
  set_primary_key :collaboration_id

end
