# active_record_decorator
# This gem is still in developement
The idea bedind this gem is to additional functionality for active record ORM module in rails to make day-to-day application development easy.
ActiveRecord is a very powerful tool and extensively used in most Rails apps. When working on application developement we might hit upon certain situation where we felt like "It would be great if Activerecord would have given us this". ActiveRecord as a framework solved many generic cases like scopes, callbacks, relationships to larger extent. But as app application developement evolves we might face some intuitive features which does not make sense at framework level but it does make sense at application development level. Moreover ActiveRecord cannot provide all exhaustive features the whole world wants. But it definitely has the building blocks on which develeopers like us can write abstraction upon which helps others by sharing

# Installation

`gem install active_record_decorator`

# Usage

## Most of us would have stumbled up following similar use case
### #conditional_scopes
```
class User < ActiveRecord::Base
   scope :active_users, lambda {
     where(status: 1)
   }
end

# Controller Action

def users
  if params[:is_active]
    User.active_users
  else
    User.all
  end
end

```

## To make it simple

```
class User < ActiveRecord::Base
   include ActiveRecordDecorator
   scope :active_users, lambda {
     where(status: 1)
   }
end

# Controller Action
def users
  User.conditional_scopes(params[:is_active], :active_users)
end
```
### #conditional_includes
## To conditionally add includes

```
class User < ActiveRecord::Base
   include ActiveRecordDecorator
   has_one :image
end

# Controller Action
def users
  User.conditional_includes(params[:include] == 'image', :image)
end
```

### #on_has_one_update


