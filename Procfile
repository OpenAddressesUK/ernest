web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: env QUEUE=default TERM_CHILD=1 JOBS_PER_FORK=1000 bundle exec rake resque:work
