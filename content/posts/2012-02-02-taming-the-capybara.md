---
kind: article
title: "Taming the Capybara"
created_at: 2012-02-02 10:00
categories:
  - testing
  - capybara
  - rspec
author_name: Piotr Zolnierek
---

Recently I work a lot on Acceptance Tests and how to write them in a clean way.
When working with [RSpec](https://www.relishapp.com/rspec) and [Capybara](https://github.com/jnicklas/capybara/) I often see people wanting to go to a page and then do a couple of tests. The intent is to go to the site, login, then _describe_ what they see, which is good practice (at least in theory). 

<!-- more -->

Something like this (which I consider spaghetti coding anyway, but nice for the purpose of illustration):

```language-ruby
describe 'My Page', :type => :acceptance do
  before(:all) do 
    visit '/'
    fill_in 'email', :with => 'pzolnierek@gmail.com'
    fill_in 'password', :with => 'passw0rd'
    click_button 'login'
  end

  it 'shows a logout button' do
    page.should have_link 'logout'
  end

  it 'shows a product information box' do
    page.should have_selector '#infoBox'
  end
end
```

Trouble is that Capybara will by default reset your session after each test. Bummer! 
If you look at the Capybara source code you will find this:

```language-ruby
com/jnicklas/capybara/blob/master/lib/capybara/rspec.rb
...
config.after do
    if self.class.include?(Capybara::DSL)
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
...
```


## The OO Solution
I am currently working on another more longish article which will be about __Beautiful Acceptance Tests__ where I use an object oriented way to  write acceptance tests, but here is a tip from it.

If you want full control do the Capybara wire-up yourself. 

First we create a context object, which will hold our session.

```language-ruby
class TestUser
  include RSpec::Matchers
  include Capybara::DSL
  include Capybara::RSpecMatchers
end
```

Now you can do testing like a Boss!

```language-ruby
describe 'My Page' do
  attr_accessor :user
  before(:all) do
    @user = TestUser.new
    @user.visit '/'
  end

  it 'shows a logout button' do
    user.page.should have_link 'logout'
  end

  it 'shows a product information box' do
    user.page.should have_selector '#infoBox'
  end
end

```

Notice the missing `:type => :acceptance`. Here the `Capybara::Session` will be embedded in the TestUser instance, instead of the Nested class which is created by RSpec and thus will work across tests.

## The token authorization solution
Another even faster to implement solution for some people is to have token authorization.

```language-ruby 
describe 'My Page' do
  before(:each) do
    visit '/?token=some-fancy-token-or-guid'
  end

  it 'shows a logout button' do
    page.should have_link 'logout'
  end

  it 'shows a product information box' do
    page.should have_selector '#infoBox'
  end
end
```


