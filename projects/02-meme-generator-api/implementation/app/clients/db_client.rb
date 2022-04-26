# frozen_string_literal: true

require './app/errors/user_already_exists_error'
require 'sqlite3'

require 'bcrypt'

class DBClient
  def self.instance
    @instance ||= new
  end

  def initialize
    @db = SQLite3::Database.open 'USERS.db'
    @db.execute 'CREATE TABLE IF NOT EXISTS users(username TEXT PRIMARY KEY, password TEXT)'
    @db.execute 'CREATE TABLE IF NOT EXISTS tokens(token VARCHAR(32) PRIMARY KEY, username TEXT)'
  end

  def create_user(username, password)
    add_user(username, password)
  rescue SQLite3::ConstraintException
    raise UserAlreadyExistsError
  end

  def create_token(username, token)
    @db = SQLite3::Database.open 'USERS.db'
    @db.execute 'INSERT INTO tokens (token, username) VALUES (?, ?)',
                token, username
  ensure
    @db.close
  end

  def delete_user(username)
    @db = SQLite3::Database.open 'USERS.db'
    @db.execute 'DELETE FROM users WHERE username=?', username.to_s
  ensure
    @db.close
  end

  def delete_token(username)
    @db = SQLite3::Database.open 'USERS.db'
    @db.execute 'DELETE FROM tokens WHERE username=?', username.to_s
  ensure
    @db.close
  end

  def get_user(username)
    @db = SQLite3::Database.open 'USERS.db'
    results = @db.query 'SELECT * FROM users WHERE username=?', username
    results.next
  ensure
    results.close
    @db.close
  end

  def get_password(username)
    @db = SQLite3::Database.open 'USERS.db'
    results = @db.query 'SELECT password FROM users WHERE username=?', username.to_s
    results.next
  ensure
    results.close
    @db.close
  end

  def get_token(token)
    @db = SQLite3::Database.open 'USERS.db'
    results = @db.query 'SELECT * FROM tokens WHERE token=?', token
    results.next
  ensure
    results.close
    @db.close
  end

  private

  def add_user(username, password)
    @db = SQLite3::Database.open 'USERS.db'
    @db.execute 'INSERT INTO users (username, password) VALUES (?, ?)',
                username, password
  ensure
    @db.close
  end
end
