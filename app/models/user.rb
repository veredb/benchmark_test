require "activerecord-import"
require "benchmark"


class User < ActiveRecord::Base
  serialize :data, ActiveRecord::Coders::Hstore
end


CONN = ActiveRecord::Base.connection
TIMES = 10000

def do_inserts
    TIMES.times { User.create(:user_id => 1, :node_id => 2, :score => 3) }
end

def raw_sql
    TIMES.times { CONN.execute "INSERT INTO users (score, updated_at, node_id, user_id) VALUES(3.0, '2009-01-23 20:21:13', 2, 1) " }
end

def mass_insert
    inserts = []
    TIMES.times do
        inserts.push "(3, '2009-01-23 20:21:13', 2, 1)"
    end
    sql = "INSERT INTO users (score, updated_at, node_id, user_id) VALUES #{inserts.join(", ")}"
  #  CONN.execute sql
    ActiveRecord::Base.connection.execute(sql)
end

def activerecord_extensions_mass_insert(validate = true)
    columns = [:score, :node_id, :user_id]
    values = []
    TIMES.times do
        values.push [3, 2, 1]
    end

   User.import columns, values, {:validate => validate}
end





puts "Testing various insert methods for #{TIMES} inserts\n"
puts "ActiveRecord without transaction:"
puts base = Benchmark.measure { do_inserts }

puts "ActiveRecord with transaction:"
puts bench = Benchmark.measure { ActiveRecord::Base.transaction { do_inserts } }
puts sprintf("  %2.2fx faster than base", base.real / bench.real)

puts "Raw SQL without transaction:"
puts bench = Benchmark.measure { raw_sql }
puts sprintf("  %2.2fx faster than base", base.real / bench.real)

puts "Raw SQL with transaction:"
puts bench = Benchmark.measure { ActiveRecord::Base.transaction { raw_sql } }
puts sprintf("  %2.2fx faster than base", base.real / bench.real)

puts "Single mass insert:"
puts bench = Benchmark.measure { mass_insert }
puts sprintf("  %2.2fx faster than base", base.real / bench.real)

puts "ActiveRecord::Extensions mass insert:"
puts bench = Benchmark.measure { activerecord_extensions_mass_insert }
puts sprintf("  %2.2fx faster than base", base.real / bench.real)

puts "ActiveRecord::Extensions mass insert without validations:"
puts bench = Benchmark.measure { activerecord_extensions_mass_insert(true)  }
puts sprintf("  %2.2fx faster than base", base.real / bench.real)
