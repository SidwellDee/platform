const CLUSTERED_MODE = process.env.CLUSTERED_MODE || "false";

const queries =
  CLUSTERED_MODE === "true"
    ? [
        `CREATE TABLE Patient ON CLUSTER '{cluster}' (
				id 						String,						-- Patient.id
				version 				String NULL,
				inserted_at 			DateTime DEFAULT now(),
				last_updated 			Date NULL,
				golden_id 				String,
				source_system 			String,						-- Patient.identifier.system
				pin 					String,						-- Patient.identifier.value	
				date_of_birth 			Date,						-- Patient.birthDate
				gender 					String,						-- Patient.gender
				nationality 			String,						-- Patient.extension.nationality
				inkhundla 				String,						-- Patient.extension.inkhundla
				chiefdom 				String						-- Patient.extension.chiefdom
			) 
			ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY tuple();`,
		`CREATE TABLE Encounter(
				id String,				  					  			
				version String NULL,			  						
				inserted_at DateTime DEFAULT now(),					
				last_updated Date NULL,								
				status                String,         				
				class_system          String,                       
				class_code            String,                      
				class_display         String,                       
				patient_id            String,                      
				practitioner_id 	  String,          				
				period_start          DateTime NULL,          
				period_end            DateTime NULL,           
				reason_code_system    String,                		
				reason_code           String,                		
				reason_code_display   String,                		
				location_id           String,                		
				hospitalization_admit_source_code String, 
				hospitalization_discharge_disp_code String
			)
			ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY tuple(inserted_at);`,
        `CREATE TABLE observation_example ON CLUSTER '{cluster}' (
					id String,
					version String NULL,
					inserted_at DateTime DEFAULT now(),
					last_updated Date NULL,
					patientId String,
					observationValue Double,
				) 
				ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
				ORDER BY tuple();`,
      ]
	: [
        `CREATE TABLE Patient(
				id 						String,						
				version 				String NULL,
				inserted_at 			DateTime DEFAULT now(),
				last_updated 			Date NULL,
				golden_id 				String,
				source_system 			String,						
				pin 					String,						
				date_of_birth 			Date,						
				gender 					String,						
				nationality 			String,						
				inkhundla 				String,						
				chiefdom 				String						
			) 
			ENGINE=MergeTree
			ORDER BY tuple();`,
		`CREATE TABLE Encounter(
				id String,				  					  			
				version String NULL,			  						
				inserted_at DateTime DEFAULT now(),					
				last_updated Date NULL,								
				status                String,         				
				class_system          String,                       
				class_code            String,                      
				class_display         String,                       
				patient_id            String,                      
				practitioner_id 	  String,          				
				period_start          DateTime NULL,          
				period_end            DateTime NULL,           
				reason_code_system    String,                		
				reason_code           String,                		
				reason_code_display   String,                		
				location_id           String,                		
				hospitalization_admit_source_code String, 
				hospitalization_discharge_disp_code String
			)
			ENGINE = MergeTree
			ORDER BY (inserted_at);
			`,
        `CREATE TABLE observation_example(
					id String,
					version String NULL,
					inserted_at DateTime DEFAULT now(),
					last_updated Date NULL,
					patientId String,
					observationValue Double,
				) 
				ENGINE=MergeTree
				ORDER BY tuple();`,
      ];

module.exports = queries;
