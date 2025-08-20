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
			) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
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
			) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY tuple(inserted_at);`,
			`CREATE TABLE Observation (
				id 							    String,
				version 					    String NULL,			  						
				inserted_at 				    DateTime DEFAULT now(),					
				last_updated 				    Date NULL,	
				status 						    String,
				category_system 			    String,
				category_code 				    String,
				code_system 				    String,
				code_code 					    String,
				code_display 				    String,
				code_text 					    String,
				subject_reference 			    String,
				encounter_reference 		    String,
				practitioner_reference 		    String,
				value_type 				    	String, -- Type of the value (e.g., Quantity, CodeableConcept, etc.)
				value_quantity_value 			Decimal(18,4) NULL,
				value_quantity_unit 			String NULL,			
				value_code             			String,
    			value_display          			String,
    			value_string           			String,
				value_boolean 				    Boolean NULL,
				value_integer 				    Integer NULL,				
				value_range_low        			Decimal(18,4) NULL,
    			value_range_high       			Decimal(18,4) NULL,
				value_ratio_num        			Decimal(18,4) NULL,
    			value_ratio_den        			Decimal(18,4) NULL, 
				value_sampled_data 			    String,
				value_time 					    String,
				value_datetime 				    DateTime NULL,
				value_period_start 			    DateTime NULL,
				value_period_end 			    DateTime NULL,  
			) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY tuple(inserted_at);`,
			`CREATE TABLE DiagnosticReport
			(
				id                      String, 
				version 			    String NULL,			  						
				inserted_at 			DateTime DEFAULT now(),					
				last_updated 			Date NULL,	
				status                  String,
				category_code           String,
				category_display        String,
				code_code               String,
				code_display            String,
				subject_reference       String,
				encounter_reference     String,
				effective_datetime      DateTime NULL,
				issued                  DateTime NULL,
				performer_reference     String,
				specimen_reference      String,
				result_reference        String,
				conclusion              String,
				presented_form          String
			) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY (inserted_at);`,
			`CREATE TABLE MedicationRequest (
				id                                              String,
				version 					                    String NULL,			  						
				inserted_at 				                    DateTime DEFAULT now(),					
				last_updated 				                    Date NULL,	
				status                                          String,
				intent                                          String,
				medication_code                					String,
				medication_display             					String,
				subject_reference                               String,
				encounter_reference                             String,
				authored_on                                     DateTime NULL,
				requester_reference                             String,
				dosage_instruction_text                         String,
				dosage_instruction_timing_repeat_frequency      UInt32 NULL,
				dosage_instruction_timing_repeat_period         Float32 NULL,
				dosage_instruction_timing_repeat_period_unit    String,
				dosage_instruction_route_code                   String,
				dosage_instruction_route_display                String,
				dispense_request_quantity_value                 Float32 NULL,
				dispense_request_quantity_unit                  String,
				dispense_request_expected_supply_duration_value Float32 NULL,
				dispense_request_expected_supply_duration_unit  String,
				substitution_allowed                            Boolean NULL,
				substitution_reason_code                        String,
				substitution_reason_display                     String
			) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY inserted_at;`,
			`CREATE TABLE ServiceRequest (
				id                                              String,
				version 					                    String NULL,			  						
				inserted_at 				                    DateTime DEFAULT now(),					
				last_updated 				                    Date NULL,	
				status                                          String,
				intent											String,
				category_system									String,
				category_code									String,
				category_display								String,
				priority										String,
				code_system										String,
				code_code										String,
				code_display									String,
				authored_on										DateTime NULL,
				note_text										String,
				subject_reference								String,
				encounter_reference								String,
				practitioner_reference							String,
				specimen_reference								String,	
			) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
			ORDER BY inserted_at;`
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
			ORDER BY tuple(inserted_at);
			`,
			`CREATE TABLE Observation (
				id 							    String,
				version 					    String NULL,			  						
				inserted_at 				    DateTime DEFAULT now(),					
				last_updated 				    Date NULL,	
				status 						    String,
				category_system 			    String,
				category_code 				    String,
				code_system 				    String,
				code_code 					    String,
				code_display 				    String,
				code_text 					    String,
				subject_reference 			    String,
				encounter_reference 		    String,
				practitioner_reference 		    String,
				value_type 				    	String, -- Type of the value (e.g., Quantity, CodeableConcept, etc.)
				value_quantity_value 			Decimal(18,4) NULL,
				value_quantity_unit 			String NULL,			
				value_code             			String,
    			value_display          			String,
    			value_string           			String,
				value_boolean 				    Boolean NULL,
				value_integer 				    Integer NULL,				
				value_range_low        			Decimal(18,4) NULL,
    			value_range_high       			Decimal(18,4) NULL,
				value_ratio_num        			Decimal(18,4) NULL,
    			value_ratio_den        			Decimal(18,4) NULL, 
				value_sampled_data 			    String,
				value_time 					    String,
				value_datetime 				    DateTime NULL,
				value_period_start 			    DateTime NULL,
				value_period_end 			    DateTime NULL,    
			) ENGINE = MergeTree
			ORDER BY tuple(inserted_at);`,
			`CREATE TABLE DiagnosticReport
			(
				id                      String, 
				version 			    String NULL,			  						
				inserted_at 			DateTime DEFAULT now(),					
				last_updated 			Date NULL,	
				status                  String,
				category_code           String,
				category_display        String,
				code_code               String,
				code_display            String,
				subject_reference       String,
				encounter_reference     String,
				effective_datetime      DateTime NULL,
				issued                  DateTime NULL,
				performer_reference     String,
				specimen_reference      String,
				result_reference        String,
				conclusion              String,
				presented_form          String
			)
			ENGINE = MergeTree
			ORDER BY (inserted_at);`,
			`CREATE TABLE MedicationRequest (
				id                                              String,
				version 					                    String NULL,			  						
				inserted_at 				                    DateTime DEFAULT now(),					
				last_updated 				                    Date NULL,	
				status                                          String,
				intent                                          String,
				medication_code                					String,
				medication_display             					String,
				subject_reference                               String,
				encounter_reference                             String,
				authored_on                                     DateTime NULL,
				requester_reference                             String,
				dosage_instruction_text                         String,
				dosage_instruction_timing_repeat_frequency      UInt32 NULL,
				dosage_instruction_timing_repeat_period         Float32 NULL,
				dosage_instruction_timing_repeat_period_unit    String,
				dosage_instruction_route_code                   String,
				dosage_instruction_route_display                String,
				dispense_request_quantity_value                 Float32 NULL,
				dispense_request_quantity_unit                  String,
				dispense_request_expected_supply_duration_value Float32 NULL,
				dispense_request_expected_supply_duration_unit  String,
				substitution_allowed                            Boolean NULL,
				substitution_reason_code                        String,
				substitution_reason_display                     String
			) ENGINE = MergeTree()
			ORDER BY inserted_at;`,
			`CREATE TABLE ServiceRequest (
				id                                              String,
				version 					                    String NULL,			  						
				inserted_at 				                    DateTime DEFAULT now(),					
				last_updated 				                    Date NULL,	
				status                                          String,
				intent											String,
				category_system									String,
				category_code									String,
				category_display								String,
				priority										String,
				code_system										String,
				code_code										String,
				code_display									String,
				authored_on										DateTime NULL,
				note_text										String,
				subject_reference								String,
				encounter_reference								String,
				practitioner_reference							String,
				specimen_reference								String,	
			) ENGINE = MergeTree()
			ORDER BY inserted_at;`
		];

module.exports = queries;
