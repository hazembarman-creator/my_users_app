#!/usr/bin/env ruby
require_relative 'my_user_model'

# This script tests the User model directly
# Concept: UNIT TESTING - testing individual components in isolation

puts "=" * 60
puts "TESTING USER MODEL"
puts "=" * 60

# Clean up - delete old database to start fresh
# Concept: TEST ISOLATION - each test run starts with clean state
File.delete('db.sql') if File.exist?('db.sql')

# Test 1: Create User
# Concept: CREATE operation (C in CRUD)
puts "\n[TEST 1] Creating a user..."
user1 = User.create({
  firstname: 'John',
  lastname: 'Doe',
  age: 25,
  password: 'secret123',
  email: 'john@example.com'
})

if user1.nil?
  puts "❌ FAILED: User creation returned nil"
else
  puts "✅ PASSED: User created with ID: #{user1.id}"
  puts "   Firstname: #{user1.firstname}"
  puts "   Type: #{user1.class}"  # Should be OpenStruct
end

# Test 2: Find User
# Concept: READ operation (R in CRUD)
puts "\n[TEST 2] Finding user by ID..."
found_user = User.find(user1.id)

if found_user.nil?
  puts "❌ FAILED: Could not find user"
elsif found_user.firstname == 'John'
  puts "✅ PASSED: Found user #{found_user.firstname} #{found_user.lastname}"
  puts "   Type: #{found_user.class}"
else
  puts "❌ FAILED: Wrong user data"
end

# Test 3: Update User with Symbol
# Concept: UPDATE operation with SYMBOL attribute
puts "\n[TEST 3] Updating user firstname with SYMBOL..."
updated_user = User.update(user1.id, :firstname, 'Johnny')

if updated_user.nil?
  puts "❌ FAILED: Update returned nil"
elsif updated_user.firstname == 'Johnny'
  puts "✅ PASSED: Updated firstname to #{updated_user.firstname}"
else
  puts "❌ FAILED: Firstname not updated (got: #{updated_user.firstname})"
end

# Test 4: Update User with String
# Concept: UPDATE operation with STRING attribute
puts "\n[TEST 4] Updating user lastname with STRING..."
updated_user2 = User.update(user1.id, 'lastname', 'Smith')

if updated_user2.nil?
  puts "❌ FAILED: Update returned nil"
elsif updated_user2.lastname == 'Smith'
  puts "✅ PASSED: Updated lastname to #{updated_user2.lastname}"
else
  puts "❌ FAILED: Lastname not updated"
end

# Test 5: Get All Users
# Concept: READ ALL operation
puts "\n[TEST 5] Getting all users..."
all_users = User.all

if all_users.empty?
  puts "❌ FAILED: No users found"
else
  puts "✅ PASSED: Found #{all_users.size} user(s)"
  all_users.each do |id, user|
    puts "   User #{id}: #{user['firstname']} #{user['lastname']}"
    puts "   Type: #{user.class}"  # Should be Hash
  end
end

# Test 6: Create Multiple Users
# Concept: BULK operations
puts "\n[TEST 6] Creating multiple users..."
user2 = User.create({
  firstname: 'Alice',
  lastname: 'Wonder',
  age: 30,
  password: 'alice123',
  email: 'alice@example.com'
})

user3 = User.create({
  firstname: 'Bob',
  lastname: 'Builder',
  age: 35,
  password: 'bob123',
  email: 'bob@example.com'
})

all_users = User.all
if all_users.size == 3
  puts "✅ PASSED: Now have #{all_users.size} users"
else
  puts "❌ FAILED: Expected 3 users, got #{all_users.size}"
end

# Test 7: Destroy User
# Concept: DELETE operation (D in CRUD)
puts "\n[TEST 7] Destroying a user..."
result = User.destroy(user2.id)

if result == true
  puts "✅ PASSED: User destroyed successfully"
  all_users = User.all
  puts "   Remaining users: #{all_users.size}"
else
  puts "❌ FAILED: Could not destroy user"
end

# Test 8: Try to Find Destroyed User
# Concept: VALIDATION - ensuring deleted data is gone
puts "\n[TEST 8] Trying to find destroyed user..."
deleted_user = User.find(user2.id)

if deleted_user.nil?
  puts "✅ PASSED: Destroyed user not found (correct!)"
else
  puts "❌ FAILED: Destroyed user still exists"
end

puts "\n" + "=" * 60
puts "MODEL TESTS COMPLETE"
puts "=" * 60