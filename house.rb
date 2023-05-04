# find house instances that aren't in a tag declaration
def find_house(text)
  regex = /(?<!>)(?<h>house|House)/ # find all house not in span
  matches = text.enum_for(:scan, regex).map{ Regexp.last_match }
  tagex = /(alt|class|id)=".*?(?<!>)(house|House)/
  output = []

  matches.each do |match|
    start = match.begin(:h)
    res = text[(start - 30).clamp(0..), match.captures[0].length + 30].match(tagex)

    unless res
      o = {:start => start, :length => match.captures[0].length, :capture => match.captures[0]}
      puts o
      output << o
    end
  end

  output
end


# split string and replace. inefficient but it works
def replace_houses(text)
  matches = find_house text
  return text if matches.empty?

  chunks = []

  matches.each_with_index do |el, i|
    start_offset = if i == 0 then
      0
    else
      matches[i-1][:start] + matches[i-1][:length]
    end

    chunks << text[start_offset..el[:start]-1]
    chunks << text[el[:start], el[:length]]

    chunks << text[(el[:start] + el[:length])..(text.length-1)] if i == matches.length-1
  end

  res = ""
  chunks.each_with_index do |el, i|
    if i == chunks.length - 1
      res << el
      next
    end

    res << if i % 2 == 0
      el
    else
      "<span class=\"house\">#{el}</span>"
    end
  end

  return res
end


puts "Performing house processing..."

Dir["#{ARGV[0]}/**/*.html"].each do |path|
  # read and process text
  file = File.open(path, mode = "r")
  text = replace_houses file.read
  file.close
  # write
  file = File.open(path, mode = "w+")
  file.write text
  file.flush
  file.close
end

