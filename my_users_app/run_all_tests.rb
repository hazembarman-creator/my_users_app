#!/usr/bin/env ruby

# This script runs all tests in sequence
# Concept: TEST AUTOMATION

puts "\n" + "=" * 70
puts " COMPLETE TEST SUITE FOR MY_USERS_APP"
puts "=" * 70

# Clean database before starting
puts "\n🧹 Cleaning up old database..."
File.delete('db.sql') if File.exist?('db.sql')
File.delete('cookies.txt') if File.exist?('cookies.txt')

# Step 1: Test Model
puts "\n" + "=" * 70
puts " STEP 1: TESTING MODEL (DATABASE LAYER)"
puts "=" * 70
system('ruby test_model.rb')

# Step 2: Start Server (user needs to do this manually)
puts "\n" + "=" * 70
puts " STEP 2: TESTING CONTROLLER (API LAYER)"
puts "=" * 70
puts "\n⚠️  IMPORTANT: Make sure your server is running!"
puts "   In another terminal, run: ruby app.rb"
puts "   Press ENTER when server is ready..."
gets

# Give user a chance to start server
puts "\n🚀 Starting controller tests..."
sleep(2)

system('bash test_controller.sh')

puts "\n" + "=" * 70
puts " ALL TESTS COMPLETE!"
puts "=" * 70
puts "\n📊 Check the output above for any failures"
puts "💡 Focus on fixing routes that returned errors\n\n"