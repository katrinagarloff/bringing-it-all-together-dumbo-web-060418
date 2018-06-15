class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.find_or_create_by(name:, breed:)
    a_dog = DB[:conn].execute(
      "SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !a_dog.empty?
        dog_data = a_dog[0]
        a_dog = self.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
      else
        a_dog = self.create(name: name, breed: breed)
      end
      a_dog
  end

  def self.find_by_id(id_to_find)
    sql = <<-SQL
      SELECT * FROM dogs where dogs.id = ?;
    SQL
    DB[:conn].execute(sql, id_to_find).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(hash)
    new_dog = self.new(name: hash[:name], breed: hash[:breed])
    new_dog.save
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
  new_dog = self.new(name: row[1], breed: row[2], id: row[0])
  new_dog
end

def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs where dogs.name = ?;
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
 end

def save

  if self.id != nil
    self.update
  else
  sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
  SQL

  DB[:conn].execute(sql, self.name, self.breed)
  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end
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
