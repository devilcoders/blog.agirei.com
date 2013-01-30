---
title: "Depend on abstractions only"
created_at: 2013-01-30 05:48
kind: article
categories:
  - hexagonal
  - di
  - ioc
author_name: Piotr Zolnierek
---

Inversion of control could be understood as synonymous to hexagonal architecture or ports and adapters. At least that's what in my, not so humble opinion, it boils down to. It helps to make your application better understandable and open for changes in the future.

<!-- more -->

The fundamental idea in a hexagonal architecture is to use inversion of control or in other words to ***depend upon abstractions only*** when it comes to external components. As an aside, dependency injection, is just one technique to achieve this, another might be a service locator pattern.

##  An simplistic example, logging ##
Given that we have an application, which is small-ish today, but we assume will grow in complexity over time.

We could easily sprinkle our code with logger.info() statements, where logger is a global variable. You can see this in many notable gems, apps.

The first thing I dislike about using the builtin ruby logger or any other replacement is that the use slightly different arguments, one uses argument and block, another different params and so on. But that's fine! Everyone has his one view of how things should be. For my particular application I have different needs than the rest of the world and that's why ***my*** logger needs to have within my application it's own protocol or interface.

I need to log informational message and I need to handle with errors.

~~~language-ruby
class LoggerAdapter
	def info(facility, short, full=nil)
	end
	def error(facility, short, full=nil)
	end
end
~~~

In my logs I want to know - in a structured way - where the message came from, the class or module, a short message and optionally a long description. A web page for viewing logs displays the facility and short message, the full message with all nitty-gritty details can be viewed when clicked. In other scenarios, the short message might be for the end-user, the full message might contain sensitive data for the developers.

The two methods above are the only one I will use in my application, I don't need debugging or anything else.

## Wrapping external dependencies ##
Now, we need to communicate with the outside world (Monads anybody?). Now of course you could substitute the standard logger in your web application with your own implementation, but then you need to implement all the methods in that interface because somebody else might expect that it should behave like a standard ruby logger. This way you make it explicit. That this is part of your domain. Some might argue that logging is not part of the domain, ever, but let's leave this discussion aside and go on with the bold assumption that in this particular case it is (I can totally prove this on a real world example - ask me at the next (drug meeting)[http://drug.org.pl] or at some conference).

~~~language-ruby
class LoggerAdapter
	def initialize
		@syslog = Syslogger.new
		@logger = Lumberjack::Logger.new("application.log", :time_format => "%m/%d/%Y %H:%M:%S")
	end

	def info(facility, short, full=nil)
		@logger.info("#{category} - #{short}\n#{full}")
	end

	def error(facility, short, full=nil)
		@syslog.log("#{category} - #{short})
		@logger.error("#{category} - #{short}\n#{full}")
	end
end
~~~

All external dependencies are handled in this adapter. Their details do not leak into the application. Changing behavior becomes easy. And in a test this can be easily stubbed.

## An Use Case Implementation

~~~language-ruby
class SomeUseCase
	def initialize(logger=LoggerAdapter.new, another_dep=Dependency.new)
		@logger, @another_dep = logger, another_dep
	end

	def call
		begin
			result = work
			@logger.info("some use case", "Success: #{result}")
			result
		rescue => ex
			@logger.error("some use case", ex.message, ex)
		end
	end

	def work
		# actual work done here
		@another_dep.do_stuff()
	end
end
~~~

Take notice that the inner hexagon - the use case object, receives readily instantiated objects for the collaboration! We depend only on the abstraction of the loggers, their implementation details along with instantiation are encapsulated in the adapter.

## Testing with adapters ##
This becomes piece of cake, it adheres to the rule, that you should only test what you own, or as Michael Feathers puts it, you test at the seams.

~~~language-ruby
describe Something do
	it "works on a sunny day" do
		logger = stub(:info => nil, :error => nil)
		use_case = SomeUseCase.new(logger)
		logger.should_receive(:info)
		use_case.call.should == "done"
	end
end
~~~
As loging is part of this use cases domain, we also needed to make sure, that the info has been called, additionally we could have verified the log message itself.

## Conclusions ##
1. Creating adapters is not only to be able to do dependency injection for better testability, but also as a way to work with code as you understand it best.
2. Every software created in more than 1-2 weeks of work, requires some architecture.
3. Ruby is not immune to the design problems discovered in Java, Cpp, etc, hence learning some more seasoned language will be benefitial to our expertise in Ruby.

