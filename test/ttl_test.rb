require 'test/test_helper'
require 'aws-sdk'

TEST_SERVER_TTL_SECONDS = 1

class TtlTest < Test::Unit::TestCase
  def setup
    @creds = Aws::Credentials.new('123', 'abc')
    @s3    = Aws::S3::Client.new(credentials: @creds, region: 'us-east-1', endpoint: 'http://localhost:10453/')
    @resource = Aws::S3::Resource.new(client: @s3)
  end

  def test_reap_specified_bucket
    bucket = @resource.create_bucket(bucket: 'ttl_bucket')
    bucket.objects.each(&:delete)
    object = bucket.object('key')
    object.put(body: 'body')

    object.get
    sleep TEST_SERVER_TTL_SECONDS
    assert_raise Aws::S3::Errors::NoSuchKey do
      object.get
    end
  end

  def test_no_reap_unspecified_bucket
    bucket = @resource.create_bucket(bucket: 'non_ttl_bucket')
    bucket.objects.each(&:delete)
    object = bucket.object('key')
    object.put(body: 'body')

    object.get
    sleep TEST_SERVER_TTL_SECONDS
    object.get
  end
end
