[![Build Status](https://travis-ci.org/OpenAddressesUK/ernest.svg)](https://travis-ci.org/OpenAddressesUK/ernest)
[![Dependency Status](http://img.shields.io/gemnasium/OpenAddressesUK/ernest.svg)](https://gemnasium.com/OpenAddressesUK/ernest)
[![Code Climate](http://img.shields.io/codeclimate/github/OpenAddressesUK/ernest.svg)](https://codeclimate.com/github/OpenAddressesUK/ernest)
[![Badges](http://img.shields.io/:badges-4/4-ff6799.svg)](https://github.com/badges/badgerbadgerbadger)

# Ernest

![](http://www.ernestmarples.com/images/go.jpg)

Ernest is the 'master' database for  OpenAddresses. Registered users can post addresses via the API, together with provenance information, saying how the address was generated.

## Dependencies

As well as Ruby 2.1.3, you'll also need:

* [MySQL](http://www.mysql.com/) or [MariaDB](https://mariadb.com/) installed (we recommend MariaDB 10.0 or above)
* [Redis](http://redis.io/)

## Installing

### Clone the repo

`git@github.com:OpenAddressesUK/ernest.git`

### Bundle

`bundle install`

### Run database migrations

`bundle exec rake db:create && bundle exec rake db:migrate`

### Run the server

`bundle exec rackup`

### Run the worker

In another Terminal window, run:

`bundle exec sidekiq -r ./lib/ernest.rb`

## Adding addresses

**Note: We are currently not accepting addresses from users to the live system during the alpha period, but if you want to add addresses to your development instance, you can follow the instructions below**

### Open the console

`./console`

### Create a user

From the console run:

`user = User.create(name: "YOUR NAME", email: "YOUR EMAIL")`

### Get an API key

Still in the console run:

`name.api_key`

Note this down for future reference.

### Post to Ernest

With the server running, create some JSON in this format:

```JSON
{
  "addresses": [
    {
      "address": {
        "paon": "3",
        "street": "Hobbit Drive",
        "locality": "Hobbitton",
        "town": "The Shire",
        "postcode": "ABC 123"
      },
      "provenance": {
        "executed_at": "2014-01-01T13:00:00Z",
        "url": "http://www.example.com"
      }
    }
  ]
}
```

The `"addreses"` array can contain any number of addresses.

You can then `POST` your payload to the app like so (assuming your server is running at http://localhost:9292/)

```
curl -v -H "Content-Type: application/json" -H "ACCESS_TOKEN: YOUR_API_KEY" -d '{"addresses":[{"address":{"paon":"3","street":"Hobbit Drive","locality":"Hobbitton","town":"The Shire","postcode":"ABC 123"},"provenance":{"executed_at":"2014-01-01T13:00:00Z","url":"http://www.example.com"}}]}' http://localhost:9292/addresses
```

You should get a `202 Accepted` HTTP response, and your running worker should process the response.

### Listing addresses

You can see your newly added address at `http://localhost:9292/addresses`
