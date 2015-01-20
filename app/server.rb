content = []
contentArray = []
content = File.open("amazing2.txt")

content.each do |line|
  if line.include? "("
    lineNew = line.slice(0,line.index("("))
    contentArray.push(lineNew.strip)
  else
  contentArray.push(line.chomp)
  end
end

p contentArray
