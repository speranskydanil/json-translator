# JSON Translator

A library to transform json from one scheme to another.

## Installing

    gem install json-translator

    require 'json-translator'

## Quick example

Suppose we use API which responses with next simple json:

    json = <<-json
    {
       "total":2,
       "page":1,
       "perPage":5,
       "requestLimit":7,
       "results":[
          {
             "id":21,
             "status":"active",
             "accountName":"daz143",
             "money":500.0,
             "personalInformation":{
                "age":23,
                "city":"Novosibirsk",
                "firstName":"Danil",
                "lastName":"Speranskiy"
             },
             "documents":[
                {
                   "title":"Note #1",
                   "htmlContent":"\u003cp\u003eok\u003c/p\u003e"
                },
                {
                   "title":"Note #2",
                   "htmlContent":"\u003ch3\u003eHi there!\u003c/h3\u003e"
                }
             ]
          },
          {
             "id":22,
             "status":"deleted",
             "accountName":"damaty",
             "money":63.24,
             "personalInformation":{
                "age":24,
                "city":"Berdsk",
                "firstName":"Dmitry",
                "lastName":"Kirichenko"
             },
             "documents":[
                {
                   "title":"I am the good",
                   "htmlContent":"\u003cb\u003eyep\u003c/b\u003e"
                }
             ]
          }
       ]
    }
    json

Now we want to change the json scheme.

```ruby
hash = JT.t(json) do
  # save as it is
  total

  # rename 'results' to :users
  # map each user with code below
  iterate :users, :results do
    status

    # scopes allow you to fetch data from nested objects
    scope :personalInformation do
      age
      city
    end

    # namespaces allow you to provide nesting in resulting hash
    namespace :account_info do
      money
      # rename 'accountName' to :account_name
      account_name 'accountName'
    end

    iterate :docs, :documents do
      title
      # rename 'htmlContent' to :text
      text 'htmlContent'
    end
  end
end

pp hash
```

The output will be:

```ruby
{:total=>2,
 :users=>
  [{:status=>"active",
    :age=>23,
    :city=>"Novosibirsk",
    :account_info=>{:money=>500.0, :account_name=>"daz143"},
    :docs=>
     [{:title=>"Note #1", :text=>"<p>ok</p>"},
      {:title=>"Note #2", :text=>"<h3>Hi there!</h3>"}]},
   {:status=>"deleted",
    :age=>24,
    :city=>"Berdsk",
    :account_info=>{:money=>63.24, :account_name=>"damaty"},
    :docs=>[{:title=>"I am the God", :text=>"<b>yep</b>"}]}]}
```

## Shortcuts

Methods `iterate`, `scope`, `namespace` have one symbol shorcuts:

```ruby
hash = JT.t(json) {
  total

  iterate(:users, :results) {
    status

    s(:personalInformation) { age; city }
    n(:account_info) { money; account_name 'accountName' }
    i(:docs, :documents) { title; text 'htmlContent' }
  }
}
```

## Syntax with '.' symbol

Scopes and namespaces support syntax with '.' symbol to avoid block nesting.
For json:

```ruby
json = <<-json
{
   "user":{
      "name":"Speransky Danil",
      "age":23,
      "city":"Novosibirsk",
      "account":{
         "money":500.0,
         "cart":{
            "total":2,
            "items":[
               {
                  "productId":143,
                  "count":1
               },
               {
                  "productId":245,
                  "count":2
               }
            ]
         }
      }
   }
}
json
```

Instead of

```ruby
hash = JT.t(json) {
  s(:user) {
    name
    s(:account) {
      s(:cart) {
        items_count 'total'
      }
    }
  }
}

pp hash #=> {:name=>"Speransky Danil", :items_count=>2}
```

You write

```ruby
hash = JT.t(json) {
  s(:user) {
    name
    s('account.cart') { items_count 'total' }
  }
}

pp hash #=> {:name=>"Speransky Danil", :items_count=>2}
```

## Notices

* `JT.t` accepts json string or hash or array
* Itaratings, scopes and namespaces could be nested in any order and arbitrary number of times

**Author (Speransky Danil):**
[Personal Page](http://dsperansky.info) |
[LinkedIn](http://ru.linkedin.com/in/speranskydanil/en) |
[GitHub](https://github.com/speranskydanil?tab=repositories) |
[StackOverflow](http://stackoverflow.com/users/1550807/speransky-danil)

