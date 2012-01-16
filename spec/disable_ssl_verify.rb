require 'openssl'
# This is necessary because there doesn't seem to be a consistent way
# to specify a CA to trust across all the various uses of Net::HTTP in
# all the libraries everywhere.
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
