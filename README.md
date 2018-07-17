# Elasticsearch::Index::Transfer

Ruby gem for transfering elasticsearch index data from one source to another. Currently this gem can transfer elasticsearch index data between

* elasticsearch to elasticsearch
* elasticsearch to s3(AWS S3)
* s3 to elasticsearch

This gem is using [scroll API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html) provided by elasticsearch for backing up the elasticsearch index data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'elasticsearch-index-transfer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elasticsearch-index-transfer

## Usage

If you are using irb console

```ruby
require 'elasticsearch-index-transfer'
```

#### From one elasticsearch host to another elasticsearch host
```ruby
options = {
            "source": {
              "elasticsearch": {
                "host": * source-host-ip *,
                "port": * source-host-port *,
                "index": * elasticsearch-index-name *
              }
            },
            "target": {
              "elasticsearch": {
                "host": * target-host-ip *,
                "port": * target-host-port *,
                "index": * elasticsearch-index-name *
              }
            }
          }
Elasticsearch::Index::Transfer.execute(options)
```

#### From elasticsearch host to s3(AWS S3)
```ruby
options = {
            "source": {
              "elasticsearch": {
                "host": * source-host-ip *,
                "port": * source-host-port *,
                "index": * elasticsearch-index-name *
              }
            },
            "target": {
              "s3": {
                "region": * S3-region-name *,
                "access_key_id": * S3-access-key-id *,
                "secret_access_key": * S3-secret-access-key *,
                "bucket": * S3-bucket-name *,
                "prefix": * S3-folder/prefix * # optional 
              }
            }
          }
Elasticsearch::Index::Transfer.execute(options)
```

#### From s3(AWS S3) to elasticsearch host
This gem can only transfer data from AWS S3 to elasticsearch host only if backup on S3 is made by this gem only.

```ruby
options = {
            "source": {
              "s3": {
                "region": * S3-region-name *,
                "access_key_id": * S3-access-key-id *,
                "secret_access_key": * S3-secret-access-key *,
                "bucket": * S3-bucket-name *,
                "prefix": * S3-folder/prefix * # optional 
              }
            },
            "target": {
              "elasticsearch": {
                "host": * targer-host-ip *,
                "port": * target-host-port *,
                "index": * elasticsearch-index-name * # if index name not given it will use index name of backed up index.
              }
            },
            
          }
Elasticsearch::Index::Transfer.execute(options)
```

## Test
  rspec spec/elasticsearch-index-transfer.rb

## Contribute

Issue Tracker: [https://github.com/imran3180/elasticsearch-index-transfer/issues](https://github.com/imran3180/elasticsearch-index-transfer/issues)

Pull Request: [https://github.com/imran3180/elasticsearch-index-transfer/pulls](https://github.com/imran3180/elasticsearch-index-transfer/pulls)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
