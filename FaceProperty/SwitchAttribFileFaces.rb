#!/usr/bin/env ruby

#mesh_face_ids = {old,new}
#old_face_id = fixnum
def search_face_ids(mesh_face_ids, old_face_id)
	mesh_face_ids.each_key do |id|  #iterate over each old face id 
		if id == old_face_id then #if we find the one we're looking for
			return mesh_face_ids[id] #return the corresponding new one
		end
	end	
	throw "no result found"
end


mesh_face_file = File.new(ARGV[0],"r") #list of numbers
attribute_file = File.new(ARGV[1],"r") #starts with "version 1"
ofile = File.new("output","w")
face_lines = mesh_face_file.readlines

mesh_face_ids = {}

face_lines.each do |l|
	x=l.match('([0-9]+)([\s\t\r\n\f])([0-9]+)')
	if x != nil then
		mesh_face_ids[x[1]] = x[3] # mesh_face_ids[old] = new
	end
end

attribute_file_lines = attribute_file.readlines

afl = {}
output_af = [] 
i = 0
corrected_faces = 0
removed_faces = 0
while i < attribute_file_lines.size do
	l = attribute_file_lines[i]
	old_face_id = nil
	old_face_id_line = (l.match('^(2)([\s\t\r\n\f])([0-9]+)(.*)'))
	old_face_id = old_face_id_line[3] unless old_face_id_line == nil
	if old_face_id != nil then
		begin
			new_face_id = search_face_ids(mesh_face_ids, old_face_id)
			#replace value  
			output_af << l.sub(old_face_id,new_face_id).chomp() + ' #' + "Corrected\n"
			i=i+1
			corrected_faces = corrected_faces + 1
		rescue
			output_af << ('#' + l.chomp() +  ' #' + "Match Not Found\n")
			output_af << ('#' + attribute_file_lines[i+1])
			i = i+2
			removed_faces +=1
		end
	else
		output_af << l
		i=i+1
	end
end
output_af.each { |l| ofile.puts(l) }
puts "Corrected #{corrected_faces} Attributes"
puts "Removed #{removed_faces} Attributes"
