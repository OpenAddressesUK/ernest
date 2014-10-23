web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: env QUEUE=default TERM_CHILD=1 bundle exec rake resque:work
