# -*- encoding : utf-8 -*-
Rails.application.config.middleware.use OmniAuth::Builder do
  #  provider :facebook, '351819461522684', 'd0338f4f18d582c2a5517f548bc10f99'
  provider :twitter , 'VquRJTWc2k5dT4OKIKkLmA', 'UCHbzn2E8iAadWeI5jyMUZDwYAGYrz9v7yBjW3HXVY'
#  Local App credentials
#  provider :facebook, "351819461522684", "d0338f4f18d582c2a5517f548bc10f99", {:scope => 'manage_pages,publish_stream,offline_access,email,user_birthday,user_location,user_hometown'}
  provider :facebook, "391300874239877", "3923e65177979c4f61371bdf60dffd61", {:scope => 'manage_pages,publish_stream,offline_access,email,user_birthday,user_location,user_hometown'}
end

