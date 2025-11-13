
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
	df = pd.DataFrame(columns=["name", "genre", "is_child_of"])

	#create nf male to be fathers individuals
	for n in range(int(args.nb_fathers)):
		father_id = "".join(["father_", str(n+1)])
		new_father = pd.DataFrame({"name": [father_id], 
								"genre": ["Male"],
								"is_child_of": None})
		df = pd.concat([df, new_father], ignore_index=True)

		#randomly decide if the individual has child
		if choice(range(2)):
			#randomly decide how many children he has
			nb_children = choice(range(4))

			for new_child in range(nb_children):
				child_id = "".join(["child_nb_", str(new_child+1), "_of_", str(n)])
				#randomly decide the genre of the child
				if choice(range(2)):
					new_child = pd.DataFrame({"name": [child_id], 
											"genre": ["Female"],
											"is_child_of": [father_id]})
				else:
					new_child = pd.DataFrame({"name": [child_id], 
											"genre": ["Male"],
											"is_child_of": [father_id]})

				#Add the child to the father
				df = pd.concat([df, new_child], ignore_index=True)

	print(df)
	dir = os.path.dirname(args.output_file_name)
	if not str(dir)=="" and not os.path.exists(dir):
		os.makedirs(dir)	
	
	df.to_csv(args.output_file_name, sep=',')
