CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => 'AKIAIWYJD4O3PQX4ETIA',       # required
      :aws_secret_access_key  => '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', # required
  }
  config.fog_directory  = 'tokenfire'                     # required
  config.fog_public     = false                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end