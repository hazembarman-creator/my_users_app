require "sqlite3"

$db_filename = "db.sql"
$tablename = "users"

class ConnectionSqLite
    def initialize
        @db = nil
    end

    def get_connection
        if @db == nil
            @db = SQLite3::Database.new($db_filename)
            createdb
        end
        @db
    end 

    def createdb
        self.get_connection().execute <<-SQL
            CREATE TABLE IF NOT EXISTS #{$tablename} (
                id INTEGER PRIMARY KEY,
                firstname varchar(30),
                lastname varchar(30),
                age int,
                password varchar(30),
                email varchar(30)
            );
        SQL
    end

    def execute(query)
        self.get_connection().execute(query)
    end
end

class User
    attr_accessor :id, :firstname, :lastname, :age, :password, :email

    def initialize(array)
        @id         = array[0]
        @firstname  = array[1]
        @lastname   = array[2]
        @age        = array[3]
        @password   = array[4]
        @email      = array[5]
    end

    def to_h
        {id: @id, firstname: @firstname, lastname: @lastname, age: @age, password: @password, email: @email}
    end

    def inspect
        %Q|<User id: #{@id}, firstname: "#{@firstname}", lastname: "#{@lastname}", age: #{@age}, password: "#{@password}", email: "#{@email}">|
    end

    def self.init_db
        ConnectionSqLite.new.createdb
    end

    def self.create(user_info)
        # Handle both string and symbol keys
        firstname = user_info['firstname'] || user_info[:firstname]
        lastname = user_info['lastname'] || user_info[:lastname]
        age = user_info['age'] || user_info[:age]
        password = user_info['password'] || user_info[:password]
        email = user_info['email'] || user_info[:email]
    
        conn = ConnectionSqLite.new
    
        query = <<-REQUEST
            INSERT INTO #{$tablename} (firstname, lastname, age, password, email) 
            VALUES ("#{firstname}", "#{lastname}", "#{age}", "#{password}", "#{email}");    
        REQUEST
    
        conn.execute(query)
    
        # Get the last inserted ID and return the user
        last_id = conn.execute("SELECT last_insert_rowid()")[0][0]
        self.find(last_id)
    end 

    def self.get(user_id)
        query = <<-REQUEST
            SELECT * FROM #{$tablename} WHERE id = #{user_id};
        REQUEST
        rows = ConnectionSqLite.new.execute(query)
    
        if rows.any?
            User.new(rows[0])
        else
            nil
        end
    end

    # Add alias for find method (tests use this)
    def self.find(user_id)
        self.get(user_id)
    end

    def self.all
        query = <<-REQUEST
            SELECT * FROM #{$tablename};
        REQUEST
        rows = ConnectionSqLite.new.execute(query)
    
        if rows.any?
            rows.collect do |row|
                User.new(row)
            end
        else
            []
        end
    end

    def self.authenticate(email, password)
        User.all.find { |user| user.email == email && user.password == password }
    end

    def self.update(user_id, attribute, value)
        query = <<-REQUEST
            UPDATE #{$tablename}
            SET #{attribute.to_s} = '#{value}'
            WHERE id = #{user_id};
        REQUEST
    
        ConnectionSqLite.new.execute(query)
        self.get(user_id)
    end

    def self.destroy(user_id)
        query = <<-REQUEST
            DELETE FROM #{$tablename}
            WHERE id = #{user_id};
        REQUEST
    
        ConnectionSqLite.new.execute(query)
    end
end