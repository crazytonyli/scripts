#!/usr/bin/ruby


def usage
    print <<USAGE
Usage: #{$0} /path/to/Header.h
This script will generate method of NSCoding protocol according to the declared
properties in Objective-C header file.
USAGE
end

WARNING="// WARNING: This object was not recognized, please DOUBLE CHECK!"

class Property
    attr_accessor :type, :name, :warning

    def encode
        case @type
        when "BOOL"
            ret = "[aCoder encodeBool:[self #{@name}] forKey:@\"#{@name}\"];"
        when "NSData"
            ret = "[aCoder encodeDataObject:[self #{@name}]];"
        when "int"
            ret = "[aCoder encodeInt:[self #{@name}] forKey:@\"#{@name}\"];"
        when "NSInteger"
            ret = "[aCoder encodeInteger:[self #{@name}] forKey:@\"#{@name}\"];"
        when "NSUInteger"
            ret = "[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self #{@name}]] forKey:@\"#{@name}\"];"
        when "double"
            ret = "[aCoder encodeDouble:[self #{@name}] forKey:@\"#{@name}\"];"
        when "float", "CGFloat"
            ret = "[aCoder encodeFloat:[self #{@name}] forKey:@\"#{@name}\"];"
        when "id", /^NS.*$/
            ret = "[aCoder encodeObject:[self #{@name}] forKey:@\"#{@name}\"]; "
        else
            ret = "[aCoder encodeObject:[self #{@name}] forKey:@\"#{@name}\"]; #{WARNING}"
        end

        return ret
    end

    def decode
        case @type
        when "BOOL"
            ret = "[aDecoder decodeBoolForKey:@\"#{@name}\"];"
        when "NSData"
            ret = "[aDecoder decodeDataObject];"
        when "int"
            ret = "[aDecoder decodeIntForKey:@\"#{@name}\"];"
        when "NSInteger"
            ret = "[aDecoder decodeIntegerForKey:@\"#{@name}\"];"
        when "NSUInteger"
            ret = "[aDecoder decodeObjectForKey:@\"#{@name}\"];"
        when "double"
            ret = "[aDecoder decodeDoubleForKey:@\"#{@name}\"];"
        when "float", "CGFloat"
            ret = "[aDecoder decodeFloatForKey:@\"#{@name}\"];"
        when "id", /^NS.*$/
            ret = "[aDecoder decodeObjectForKey:@\"#{@name}\"];"
        else
            ret = "[aDecoder decodeObjectForKey:@\"#{@name}\"]; #{WARNING}"
        end

        return ret
    end

end

if ARGV.length == 0 or !File.exists?(ARGV[0]) then
    usage()
    exit 1
end

# parse properties
properties = []
File.open(ARGV[0]).read.gsub(/\r\n?/, "\n").each_line do |line|
    if line.start_with?("@property") then
        # string with type and name
        ss = line.split(')')[1].strip!

        # remove comments
        ss.gsub!(/\/\*.*\*\//, "")

        # type, name
        sa = ss.split(/\s+/)

        # remove '*'
        sa[0].sub!(/\*/, "")
        sa[1].gsub!(/[\*;]/, "")

        # create Porperty object
        p = Property.new()
        p.type = sa[0]
        p.name = sa[1]
        properties.push(p)
    end
end

# head of method
encode = "- (void)encodeWithCoder:(NSCoder *)aCoder {\n"
decode = "- (id)initWithCoder:(NSCoder *)aDecoder {\n    if ( (self = [super init]) ) {\n"

# content of method
properties.each do |p|
    encode << "    " << p.encode << "\n"
    decode << "        " << p.decode << "\n"
end

# tail of method
encode << "}\n"
decode << "    }\n    return self;\n}\n"

# output the method content to console
print "// NSCoding - decode\n"
print decode
print "\n// NSCoding - encode\n"
print encode
