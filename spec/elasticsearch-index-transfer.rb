require 'elasticsearch/index/transfer'
require 'yaml'

describe Elasticsearch::Index::Transfer do
  it "transfer data from elasticsearch to s3" do
    configs = YAML.load_file("config/secrets.yml")
    options = {
                "source": {
                  "elasticsearch": {
                    "host": configs["elasticsearch"]["host"],
                    "port": configs["elasticsearch"]["port"],
                    "index": configs["elasticsearch"]["index"]
                  }
                },
                "target": {
                  "s3": {
                    "region": configs["s3"]["region"],
                    "access_key_id": configs["s3"]["access_key_id"],
                    "secret_access_key": configs["s3"]["secret_access_key"],
                    "bucket": configs["s3"]["bucket"],
                    "prefix": configs["s3"]["prefix"]
                  }
                }
              }
    puts options
    expect(Elasticsearch::Index::Transfer.execute(options)).to eql(true)
  end

  it "transfer data from s3 to elasticsearch" do
    configs = YAML.load_file("config/secrets.yml")
    options = {
                "source": {
                  "s3": {
                    "region": configs["s3"]["region"],
                    "access_key_id": configs["s3"]["access_key_id"],
                    "secret_access_key": configs["s3"]["secret_access_key"],
                    "bucket": configs["s3"]["bucket"],
                    "prefix": configs["s3"]["prefix"]
                  }
                },
                "target": {
                  "elasticsearch": {
                    "host": configs["elasticsearch"]["host"],
                    "port": configs["elasticsearch"]["port"],
                    "index": configs["elasticsearch"]["index"] + "-from-s3"
                  }
                }
              }
    puts options
    expect(Elasticsearch::Index::Transfer.execute(options)).to eql(true)
  end

  it "transfer data from elasticsearch to elasticsearch" do
    configs = YAML.load_file("config/secrets.yml")
    options = {
                "source": {
                  "elasticsearch": {
                    "host": configs["elasticsearch"]["host"],
                    "port": configs["elasticsearch"]["port"],
                    "index": configs["elasticsearch"]["index"]
                  }
                },
                "target": {
                  "elasticsearch": {
                    "host": configs["elasticsearch"]["host"],
                    "port": configs["elasticsearch"]["port"],
                    "index": configs["elasticsearch"]["index"] + "-from-elasticsearch"
                  }
                }
              }
    puts options
    expect(Elasticsearch::Index::Transfer.execute(options)).to eql(true)
  end
end