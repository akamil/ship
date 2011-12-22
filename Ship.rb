#!/usr/bin/env ruby
require 'rubygems'
require 'antlr3'

require 'ShipLexer.rb'
require 'ShipParser.rb'

if ARGV.size==0 
	puts "Missing input file"
	exit
end	
lexer = open( ARGV[0] ) do | f | Ship::Lexer.new( f ) end
tokens = ANTLR3::CommonTokenStream.new( lexer )
parser = Ship::Parser.new( tokens )
parser.file
