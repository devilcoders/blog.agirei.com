---
kind: article
title: "OOP Acceptance Tests with Rspec"
created_at: 2012-02-02 11:11
categories:
  - testing
author_name: Piotr Zolnierek
---
This is part two of my blog post about Acceptance Testing. In the previous post I outlined some basics, now let's get into the code.

<!-- more -->

## A real life example

The tests I will be showing you are based on a real-life example, which I have (vastly) simplified for this article.

The source code for the test application is available at [https://github.com/pzol/acceptance_testing](https://github.com/pzol/acceptance_testing)

## Know your tools
If you want to dive deep into acceptance testing, you can skip this part.

{% pullquote %}
In order to be productive and not waste time with repeating tasks, I find it very important to setup an environment which {" automates fast feedback from the first minute "} about what is going on in your application and your tests. 
{% endpullquote %}

The tools I use here are

* [Rspec](https://www.relishapp.com/rspec) 
* [Guard](https://github.com/guard/guard) - for running specs as they change
* [Capybara](https://github.com/jnicklas/capybara) - to help testing the web application

This is how my `.rspec` looks like:

    --color
    --format progress
    --fail-fast

This will format the output in color, display the output in dots (progress) format and most importantly turn on fail-fast, which will stop the tests at the first error!

For running single tests via Guard, I can override this options in the Guardfile

~~~language-ruby
guard 'rspec', :version => 2, :cli => "--format nested", :notification => true do
  watch(%r{^spec/.+_spec\.rb$})
end
~~~


You can run the application under test using  `bundle exec rackup`  
then go with your browser to `http://localhost:9292`

## Test Data

As the system shall test the application end-to-end we need some test data, I have actually exported from a real database and saved as json


## My ideal acceptance test

This is how I imagine an _acceptance test_:

~~~language-ruby
scenario 'latest transactions' do
  user = TestUser.new.extend(Role::TransactionsBrowser)
  user.visit_latest_transactions
  user.sees_transactions_table!


  user.sees_transactions_table!
  user.all_table_rows do |tr| 
    tr.timestamp.should be_a DateTime 
  end
end  
~~~

Although I generally recommend not to clutter your scenario with shoulds or asserts, sometimes having them means is faster and means much less code. Not having them adds the minor benefit, that you are not depending on a particular testing framework.

## The TestUser class

It represents the Data in DCI. For the RSpec I create an empty class and add the `Capybara::DSL` as well as the `Capybara::RSpecMatchers`. Those will make available all the nice Capybara and RSpec matchers within the `TestUser` class and also to its instances.

~~~language-ruby
class TestUser
  include RSpec::Matchers
  include Capybara::DSL
  include Capybara::RSpecMatchers
  include Role::Navigator
  include Role::Verifier
end
~~~

## The TransactionBrowser Role

It contains all the role methods which a person browsing the transactions might do.   
The transactions page contains a list of transactions which have been sent to some API.

By calling `user.sees_transactions_table!` I define that the user sees the table. We intuitively know what it means to see that table and if it is alright. So mapping this to my mental model I only have this terse command with the bang! at the end, which means this is an _assertion_.  Inside this method I describe what it means, that the table is displayed correctly.

~~~language-ruby
def sees_transactions_table!
  headers = %w[timestamp contract facility method time_taken product]
  begin 
    thead = find('#transactionsTable thead') 
  rescue Capybara::ElementNotFound
    raise("Could not find the transactionsTable in #{find('#summary').text}")
  end
  
  headers.each { |h| thead.should have_content h }
  table_rows.should have(20).rows
end
~~~

What is very important here, that we verify, that we have the correct page loaded and if not to display the error message in the test results, otherwise you will be doing a lot of 'puts-driven-development'.  

I know that Sinatra displays its error in the `#summary` div, so I pick just this to be shown in my test results, Capybara nicely strips all the html around, so it is very readable in the console:

~~~language-ruby
Could not find the transactionsTable in 
       NoMethodError at /
         
       undefined method `<<' for nil:NilClass
       file: 
           latest_transactions_context.rb
         location: block in call
           
         line:
            6
~~~


Next I verify all the table rows:

~~~language-ruby
user.all_table_rows do |tr| 
  tr.timestamp.should be_a DateTime 
  tr.contract.should == 'test'
  tr.facility.should == 'api.test'
  tr.method.should == 'hotels'
  tr.time_taken.should be_a Fixnum
  tr.product.should == 'HOTEL'
end
~~~

Ok, now that we are done with the basic sunny day scenario, we need the user to be able to search. Writing the scenario first.

~~~language-ruby
  scenario 'search by time_taken' do
    user.extend(Role::TimeTakenSearcher)
    user.visit_latest_transactions
    user.sees_transactions_table!

    user.searches_for_time_taken(time_taken = 20000)

    user.sees_transactions_table!

    user.all_table_rows do |tr|
      tr.time_taken.should > time_taken
    end
  end
~~~

I can reuse easily the a lot of the code I used earlier. The new thing here is `user.searches_for_time_taken(time_taken = 20000)`. This will hide the ugly details of filling boxes and clicking, and is so much more readable.  
I consciously am __not__ checking for the count of rows as in the first example. I am verifying only what makes this scenario successful, which is the time_taken. This makes the tests also less brittle in case I decide to change the underlying test data later. 

I introduce a new role `Role::TimeTakenSearcher`.

~~~language-ruby
module Role
  module TimeTakenSearcher
    def searches_for_time_taken(time_taken)
      fill_in 'time_taken', :with => time_taken
      click_button'searchButton'
    end
  end
end
~~~

## Browser-less web-development promotes reliable acceptance tests
While writing the accompanying application for this article, I decided __not__ to open the browser, especially when errors occurred. It was difficult at first, but in the end it saved me a lot of time and it made my tests so much more reliable. It forced me to have more descriptive error messages.

## A word about test-speed
I am a fan of [Guard](https://github.com/guard/guard), every time I save it runs the test I am working on in the background and notifies me by Growl if the test passed or not. Thus fast feedback is important for my workflow.

A single test should run fast, always, by that I mean less than 500 ms. On top of that comes the startup time. For Sinatra and Padrino that's usually 2-3 secs, for Rails... well... you might want to use Spork there.

That's another reason why you should have an object oriented design in your code, so you can use regular unit tests

Please do include unit test. Acceptance test show you if the system as a whole is working, but as they see it only from the user's point of view, they may not show you where the system is broken.

## Remember the rules 
When I write a new page, I start with the __outside-inside__ principle (or also called feature injection) and __TDD__. I create a test, describing what I expect the page to look like. Then I write the view in html or haml to make the test pass. Only then start replacing the mockup of the page with logic!


