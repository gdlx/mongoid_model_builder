# Mongoid::ModelBuilder

mongoid_model_builder dynamically creates Mongoid model classes following configuration hash specifications

## Installation

Add this line to your application's Gemfile:

    gem 'mongoid_model_builder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid_model_builder

## Usage

Create a config file for your models :

    # config/models.rb
    [
      {
        :name => 'Person',
        :fields => [
          {
            :name => 'name',
            :type => String,
            :length => 128,
            :validators => {
              :presence => true
            }
          }, {
            :name => 'email',
            :validators => {
              :presence => true,
              :format => {
                :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
              }
            }
          }, {
            :name => 'birthdate',
            :type => Date
          }
        ]
      }, {
        :name => 'Employee',
        :extends => 'Person',
        :includes => %w(Mongoid::Timestamps),
        :fields => [
          {
            :name => 'birthdate',
            :validators => {
              :presence => true
            }
          }, {
            :name => 'salary',
            :type => Float,
            :default => 1000.00
          }
        ]
      }
    ]

Build your models :

    Mongoid::ModelBuilder.load('config/models.rb')
     => [Person, Employee]

    Person.new
     => #<Person _id: ..., _type: "Person", name: nil, email: nil, birthdate: nil>

    Employee.new
     => #<Employee _id: ..., _type: "Employee", name: nil, email: nil, birthdate: nil, salary: 1000>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
