[![Build Status](https://travis-ci.org/OpenAddressesUK/ernest.svg)](https://travis-ci.org/OpenAddressesUK/ernest)
[![Dependency Status](http://img.shields.io/gemnasium/OpenAddressesUK/ernest.svg)](https://gemnasium.com/OpenAddressesUK/ernest)
[![Code Climate](http://img.shields.io/codeclimate/github/OpenAddressesUK/ernest.svg)](https://codeclimate.com/github/OpenAddressesUK/ernest)
[![Badges](http://img.shields.io/:badges-4/4-ff6799.svg)](https://github.com/badges/badgerbadgerbadger)

# Ernest

This repository is about Open Addresses' *Ingester* software component, including its database (also called "raw database" to distinguish it from the one used for publishing) and APIs. It is named "Ernest", after Ernest Marples who was [postmaster general at the time of the introduction of postcodes in the UK](http://en.wikipedia.org/wiki/Ernest_Marples).
Ernest is part of the solution Open Addresses deployed for the Alpha stage of our services. Read about Ernest [here](http://openaddressesuk.org/docs) or learn about Open Addresses in general [here](http://openaddressesuk.org).

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

With the server running, create some JSON in this format. Within the `provenance` element, you should record the URL where you obtained the data, as well as the date you executed the code.

You can also optionally pass in geometries for each feature, if you have them. Currently, we only support point data.

```JSON
{
  "addresses": [
    {
      "address": {
        "saon": {
          "name": "Flat 1"
        },
        "paon": {
          "name": 3
        },
        "street": {
          "name": "Hobbit Street",
          "geometry": {
            "type": "Point",
            "coordinates": [125.6, 10.1]
          },
        },
        "locality": {
          "name": "Hobbiton"
        },
        "town": {
          "name": "The Shire"
        },
        "postcode": {
          "name": "ABC 123",
          "geometry": {
            "type": "Point",
            "coordinates": [125.6, 10.1]
          }
        }
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

##Licence
![Creative Commons License](http://i.creativecommons.org/l/by/4.0/88x31.png "Creative Commons License") This work is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).
