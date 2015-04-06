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

Please see our Turbot instance at [http://turbot.openaddressesuk.org/](http://turbot.openaddressesuk.org/)

If you want to add addresses to a development instance, you can follow the instructions below

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

The `"addresses"` array can contain any number of addresses.

You can then `POST` your payload to the app like so (assuming your server is running at http://localhost:9292/)

```
curl -v -H "Content-Type: application/json" -H "ACCESS_TOKEN: YOUR_API_KEY" -d '{"addresses":[{"address":{"paon":"3","street":"Hobbit Drive","locality":"Hobbitton","town":"The Shire","postcode":"ABC 123"},"provenance":{"executed_at":"2014-01-01T13:00:00Z","url":"http://www.example.com"}}]}' http://localhost:9292/addresses
```

You should get a `202 Accepted` HTTP response, and your running worker should process the response.

### Provenance

You should provide some information about where your data came from in the `provenance` field. You must include a timestamp, and if it came from a URL, you can include the URL:

```
"provenance": {
  "executed_at": "2014-01-01T13:00:00Z",
  "url": "http://www.example.com"
}
```
If it was from user input, use the `userInput` field to record the original text:
```
"provenance": {
  "executed_at": "2014-01-01T13:00:00Z",
  "userInput": "10 Downing Street, London, SW1A 1AA"
}
```

You can also provide optional information about who submitted the data, or the code used to create it. `processing_script` should refer to a URL that uniquely identifies the code used, for instance a github URL with SHA:
```
"provenance": {
  "executed_at": "2014-01-01T13:00:00Z",
  "url": "http://www.example.com",
  "processing_script": "https://github.com/OpenAddressesUK/common-ETL/blob/45e73b15815f9ecab75d0513066381dc5ec48a81/CH_Bulk_Extractor.py"
}
```
Or, you can use a free-text attribution field to give a name or user ID for the submitted, especially in the case of `userInput`.
```
"provenance": {
  "executed_at": "2014-01-01T13:00:00Z",
  "userInput": "10 Downing Street, London, SW1A 1AA",
  "attribution": "Bob Fish <bob@example.com>"
}
```
### Listing addresses

You can see your newly added address at `http://localhost:9292/addresses`

##Licence
This code is open source under the MIT license. See the LICENSE.md file for full details.
