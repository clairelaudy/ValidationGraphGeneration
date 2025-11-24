
import argparse
import os
import pandas as pd

from random import choice


if __name__ == "__main__":

	parser = argparse.ArgumentParser()
	parser.add_argument("nb_fathers")
	parser.add_argument("output_file_name")
	args = parser.parse_args()
	print(args)


	#Data to be exported
	df = pd.DataFrame(columns=["name", "genre", "has_child"])

	#create nf male to be fathers individuals
	for n in range(int(args.nb_fathers)):
		father_id = "".join(["father_", str(n+1)])

		children = []
		#randomly decide if the individual has child
		if choice(range(2)):
			#randomly decide how many children he has
			nb_children = choice(range(4))

			for new_child in range(nb_children):
				child_id = "".join(["child_nb_", str(new_child+1), "_of_", str(n)])
				children.append(child_id)
				#randomly decide the genre of the child
#				if choice(range(2)):
#					new_child = pd.DataFrame({"name": [child_id], 
#											"genre": ["Female"],
#											"has_child": None})
#				else:
				new_child = pd.DataFrame({"name": [child_id], 
											"genre": ["Male"],
											"has_child": None})

				#Add the child to the father
				df = pd.concat([df, new_child], ignore_index=True)

		new_father = pd.DataFrame({"name": [father_id], 
								"genre": ["Male"],
								"has_child": ";".join(map(str, children))
							})
		df = pd.concat([df, new_father], ignore_index=True)
		
	print(df)
	dir = os.path.dirname(args.output_file_name)
	if not str(dir)=="" and not os.path.exists(dir):
		os.makedirs(dir)	
	
	df.to_csv(args.output_file_name, sep=',')
