# active_record_decorator
### This gem is still in developement! contributions are welcome!
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
Trigger callback on parent model when has_one child is updated

```
  class User < ActiveRecord::Base
   include ActiveRecordDecorator
   has_one :image
   
   on_has_one_update :image, :on_image_last_update
   
   def on_image_last_update
     update(:image_last_updated, Time.now)
   end
   
  end
   
  class Image < ActiveRecord::Base
    include ActiveRecordDecorator
    belongs_to :user
  end

```
### #condition_alias

we regularly define conditions in models coupling with column values as below

```
def order_delivered?
  status == 'delivered'
end
def user_active?
  status = 1
end
```

The above can be now simplified as

```
  class Order < ActiveRecord::Base
   
   include ActiveRecordDecorator
   condition_alias :order_delivered?, attr: :status, value: 1
  end
  => order.condition_match?(:order_delivered?)

  class User < ActiveRecord::Base
   
   include ActiveRecordDecorator
   condition_alias :user_active?, attr: :status, value: 1
  end
  => user.condition_match?(:user_active?)
```

#assign_operation

We often do update operation in place. Over period this will be spread across the codebases. I see couple of problems here.
It hinders the readability of developers, by switching route to understand what this update operation means in business domain sense.

If any change in column definition, you can foresee a mammoth task that I am gonna refer here as fellow devs. 

Instead do it yourself approach, lets define the operation and tell to perform it as below

```
  class Order < ActiveRecord::Base
    include ActiveRecordDecorator
    assign_operation :mark_as_delivered, attr: :status, value: 1
    assign_operation :payment_status, attr: :status, value: 1
  end
  
  => order.mark_as_delivered.save
  => order.mark_as_paid.save
  class User < ActiveRecord::Base
   
   include ActiveRecordDecorator
   assign_operation :make_as_active, attr: :status, value: 1
  end
  
  => user.make_as_active.save
```

#in_batches_by_column
We have got handy [batch processing](https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-in_batches) utils in rails. But one caveat here is it works on only ID column
We might stumble upon use case where we need to process on another column which might be foreign keys or any column with more distinct values. One prerequisite is column should be indexed :) for efficient retrieval.
In case if we want to get users who placed orders

```
class Order < ActiveRecord::Base 
include ActiveRecordDecorator
end

Order.in_batches_by_column(column: :user_id,batch_size: 100, start:1) do |user_ids|
  send_email_for_users(user_ids)
end

```