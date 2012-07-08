#!/usr/bin/ruby

def usage
    print <<USAGE
Usage: #{$0} /path/to/Localized.strings
Generate cocoa localized strings template file.
USAGE
end

def generateTemplate(source)
    content = "";
    File.open(source).read.each_line do |line|
        if line.strip.length == 0 or line.lstrip.start_with?('/*') then
            content << line << "\n"
        else
            key = line.split('=')[0].strip!;
            content << "#{key} = \"\";\n"
        end
    end
    return content;
end

if ARGV.length == 0 then
    usage()
    exit 1
end

if !File.exists?(ARGV[0]) then
    print "File '#{ARGV[0]}' not exists!\n"
    exit 1
end

File.open("Localizable.strings.template", 'w') do |f|
    f.write(generateTemplate(ARGV[0]))
end
