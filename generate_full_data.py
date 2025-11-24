
import argparse
import os
import pandas as pd

import random
from faker import Faker
from faker.providers import person

import petname

def generate_person(
	fake,
	df_data:pd.DataFrame ,
	accept_partner:bool ,
	age_min:int ,
	age_max:int ,
	last_name:str ,
	) -> (dict, pd.DataFrame):
	
	if age_max > 0 :
		age_min=max(age_min, 0)
		id = str(fake.unique.random_int(min=111111, max=999999))
		
		#generate name, age, genre:
		first_name = fake.first_name()
		if not last_name:
			last_name = fake.last_name()
		age = random.randint(age_min, age_max)
		genre = "male" if random.choice([True, False]) else "female"
		children = []
		pets = []
		partner = None
	
		tenant = True if random.choice([True, False]) and age > 18 else False
		owner = True if random.choice([True, False]) and age > 30 else False

		#Does the person has a partner ?
		if age>15 and accept_partner and random.choice([True, False]):
			p_last_name = fake.last_name()
			partner, df_data = generate_person(fake=fake, df_data=df_data, accept_partner=False, age_min=age_min, age_max = age_max, last_name=p_last_name)
	
		#randomly decide if the individual (aged more than 20) has child
		if age > 20 and random.choice(range(2)):
			#randomly decide how many children he has
			nb_children = random.choice(range(4))

			for new_child in range(nb_children):
				new_child = None
				if genre == "male" or partner is None:
					new_child, df_data = generate_person(fake=fake, df_data=df_data, accept_partner=True, age_min=age-60, age_max = age-20, last_name = last_name)
				else:
					new_child, df_data = generate_person(fake=fake, df_data=df_data, accept_partner=True, age_min=age-60, age_max = age-20, last_name = partner["last_name"])
				if new_child is not None:
					children.append(new_child["id"])										
		

		#randomly decide if the person has pets
		if random.choice([True, False]):
			nb_pets = random.choice(range(3))
			for p in range(nb_pets):
				pets.append(''.join([petname.Generate(2, '_'), "(", random.choice(["cat", "dog"]), ")"]))
	
		person = {"id": id ,
				"first_name": first_name ,
				"last_name": last_name ,
				"age": age ,
				"genre": genre ,
				"children" : ";".join(children) ,
				"partner" : partner['id'] if partner is not None else None ,
				"tenant" : tenant ,
				"owner" : owner ,
				"pets" : ";".join(pets) ,
				}
				
		df_data = pd.concat([df_data, pd.DataFrame([person])], ignore_index=True)
		return person, df_data
	return None, df_data
	
if __name__ == "__main__":

	parser = argparse.ArgumentParser()
	parser.add_argument("nb_persons")
	parser.add_argument("output_file_name")
	args = parser.parse_args()
	print(args)

	fake = Faker()
	fake.add_provider(person)

	#Data to be exported
	df = pd.DataFrame(columns=["first_name", "last_name", "genre", "age", "partner", "children", "pets", "tenant", "owner"])

	p=None
	
	#create nf male to be fathers individuals
	for n in range(int(args.nb_persons)):
		p, df = generate_person(fake = fake, df_data = df, accept_partner = True, age_min=10, age_max=40, last_name=None)

	print(df)
	dir = os.path.dirname(args.output_file_name)
	if not str(dir)=="" and not os.path.exists(dir):
		os.makedirs(dir)	
	
	df.to_csv(args.output_file_name, sep=',')
