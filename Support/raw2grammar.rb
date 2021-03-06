#!/usr/bin/env ruby

# This script converts a YUIDoc raw.json metadata file into a TextMate language
# grammar. It requires the erubis and json gems.

require 'rubygems'
require 'erubis'
require 'json'

EXCLUDE_CLASSES   = []
EXCLUDE_CONSTANTS = []
EXCLUDE_FUNCTIONS = ['()', 'DEFAULT_GETTER', 'DEFAULT_SETTER']
EXCLUDE_VARIABLES = []

api = JSON.parse(File.read('raw.json'))

classes   = []
constants = []
functions = []
variables = []
version   = api['version']

api['classmap'].each do |classname, classdata|
  # Classes
  classname.split('.').each do |name|
    classes << name unless name.include?('~') || EXCLUDE_CLASSES.include?(name)
  end

  # Constants/Variables/Properties
  (classdata['properties'] || {}).each do |propname, propdata|
    next if propdata['protected'] || propdata['private']
    propname = $1 if propname =~ /\.([^\.]+)$/

    if propdata['final']
      constants << propname unless EXCLUDE_CONSTANTS.include?(propname)
    else
      variables << propname unless EXCLUDE_VARIABLES.include?(propname)
    end
  end

  # Functions/Methods
  (classdata['methods'] || {}).each do |methodname, methoddata|
    next if methoddata['protected'] || methoddata['private'] || methodname =~ /\s/
    methodname = $1 if methodname =~ /\.([^\.]+)$/
    functions << methodname unless EXCLUDE_FUNCTIONS.include?(methodname)
  end
end

classes.uniq!
classes.sort!

constants.uniq!
constants.sort!

functions.uniq!
functions.sort!

variables.uniq!
variables.sort!

puts Erubis::Eruby.new(File.read('grammar.erb')).result(binding)
