Rails.application.config.middleware.use OmniAuth::Builder do
  #  provider :facebook, '351819461522684', 'd0338f4f18d582c2a5517f548bc10f99'
  provider :twitter , 'VquRJTWc2k5dT4OKIKkLmA', 'UCHbzn2E8iAadWeI5jyMUZDwYAGYrz9v7yBjW3HXVY'
  provider :facebook, "351819461522684", "d0338f4f18d582c2a5517f548bc10f99", {:scope => 'manage_pages,publish_stream,offline_access,email'}
end

