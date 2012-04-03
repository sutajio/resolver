Resolver
========

Resolver is a flexible Redis-backed high performance index and cache
solution for ActiveModel-like objects.

Setup
-----

Assuming you already have Redis installed:

    $ gem install resolver

Or add the gem to your Gemfile.

```ruby
require 'resolver'
Resolver.redis = 'redis://.../'
```

If you are using Rails, add the above to an initializer. If Redis is running
on localhost and on the default port the second line is not needed.

Example usage
-------------

```ruby
class Post < ActiveRecord::Base
  include Resolver::Key

  key :category
  key :slug, :unique => true, :global => true

end

Post.create(:category => 'News', :slug => 'example-post')

Post.find_by(:slug, 'example-post')
Post.exists_with?(:slug, 'example-post') # => true
Post.count_with(:category, 'News') # => 1
```

The ```:global => true``` option means that the key globally namespaced and is shared by all models. If global is set to false the key is instead namespaced based on the name of the model class.

Development
-----------

If you want to make your own changes to Resolver, first clone the repo and
run the tests:

    git clone git://github.com/sutajio/resolver.git
    cd resolver
    rake test

Remember to install the Redis server on your local machine.

Contributing
------------

Once you've made your great commits:

1. Fork Resolver
2. Create a topic branch - git checkout -b my_branch
3. Push to your branch - git push origin my_branch
4. Create a Pull Request from your branch
5. That's it!

Author
------

Resolver was created by Niklas Holmgren (niklas@sutajio.se) and released under
the MIT license.
