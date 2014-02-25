#
# We follow the pattern of Presenter to do ORM object extensions.
#
# __Background__
# Nowadays, when an ActiveRecords object extends an other ActiveRecords,
# the ORM does not a sane database extension. Actually, the ORM put all the
# extended objects in one table. This is completely OK for a basic website,
# and can be even faster to do such a thing.
#
# Animals: isMale:boolean
# Cats: life:integer
# Dogs: heads:integer
#
# In database we will have something like :
#
# | TYPE | LIFE | HEADS |
# +------+------+-------+
# | Cats | 9    | NULL  |
# | Dogs | NULL | 3     |
# +------+------+-------+ animals.sql
#
# But we want 3 tables to have a sane database !
#
# | ANIMAL_ID |
# +-----------+
# | 1         |
# | 2         |
# +-----------+ animals.sql
#
# | ANIMAL_ID | CAT_ID | LIFE |
# +-----------+--------+------+
# | 1         | 1      | 9    |
# +-----------+--------+------+ cats.sql
#
# | ANIMAL_ID | DOG_ID | HEADS |
# +-----------+--------+-------+
# | 2         | 1      | 3     |
# +-----------+--------+-------+ dogs.sql
#
#
# __
class Presenter
  extend Forwardable

  def initialize(params)
    params.each_pair do |attribute, value|
      self.send :"#{attribute}=", value
    end unless params.nil?
  end
end