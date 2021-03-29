require 'pry'
class Dog
    attr_accessor :name, :breed, :id

    def initialize(dog)
        @name = dog[:name]
        @breed = dog[:breed]
        @id = dog[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name text,
                breed text
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(dog)
        dog = Dog.new(dog)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog_hash = {}
        dog_hash[:id] = row[0]
        dog_hash[:name] = row[1]
        dog_hash[:breed] = row[2]
        Dog.new(dog_hash)
    end

    def self.find_by_id(id)
        dog_hash = {}
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)
        dog_hash[:id] = row[0][0]
        dog_hash[:name] = row[0][1]
        dog_hash[:breed] = row[0][2]
        Dog.new(dog_hash)
    end

    def self.find_or_create_by(dog)
        dog_hash = {}
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        row = DB[:conn].execute(sql, dog[:name], dog[:breed])

        if !row.empty?
            dog_hash[:id] = row[0][0]
            dog_hash[:name] = row[0][1]
            dog_hash[:breed] = row[0][2]
            new_dog = Dog.new(dog_hash)
        else
            new_dog = Dog.create(dog)
        end
        new_dog
    end

    def self.find_by_name(name)
        dog_hash = {}
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name)
        dog_hash[:id] = row[0][0]
        dog_hash[:name] = row[0][1]
        dog_hash[:breed] = row[0][2]
        Dog.new(dog_hash)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end
