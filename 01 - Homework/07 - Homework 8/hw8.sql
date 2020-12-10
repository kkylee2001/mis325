--Create DDL Script with common fields from both tables
drop table client_dw; 
drop view prospective_user_view;
drop view curr_user_view;

create table client_dw
(

    client_id               number                  not null, --the id of the table
    first_name              varchar(50)             not null,
    last_name               varchar(50)             not null,
    phone                   char(13)                not null,
    email                   varchar(50)             not null,
    data_source             varchar(4)              default('CURR'), --CURR or PROS
    constraint c_pk         primary key(client_id, data_source) --joint primary key

);


create or replace view prospective_user_view as
    select prospective_id, 
            pc_first_name, 
            pc_last_name, 
            email, 
            substr(phone, 2,3) || 
                '-' || substr(phone,6,3) || 
                '-' || substr(phone, 10,4) as phone,
        'PROPS' as data_source
    from prospective_user
;


create or replace view curr_user_view as
    select user_id, 
            first_name, 
            last_name, 
            email,
            substr(phone_num, 1,3) || 
                '-' || substr(phone_num,4,3) || 
                '-' || substr(phone_num, 7,4) as phone,
        'CURR' as data_source
    from curr_user_table
;


insert into client_dw
    select puv.data_source, puv.prospective_id, 
        puv.pc_first_name as first_name, 
        puv.pc_last_name as last_name,
        puv.email as email,
        puv.phone as phone
    from prospective_user_view puv left join client_dw dw
        on puv.prospective_id = dw.client_id 
        and puv.data_source = dw.data_source
    where dw.client_id is null;

--insert new current customers
    insert into client_dw
    select cuv.data_source, cuv.user_id, 
        cuv.first_name as first_name, 
        cuv.last_name as last_name,
        cuv.email as email,
        cuv.phone as phone
    from curr_user_view cuv left join client_dw dw
        on cuv.user_id = dw.client_id 
        and cuv.data_source = dw.data_source
    where dw.client_id is null;
    
--update prospective customers
    merge into client_dw dw
        using prospective_user_view puv
        on (dw.client_id = puv.prospective_id and dw.data_source = 'PROS')
    when matched then 
        update set  dw.first_name = puv.pc_first_name, 
                    dw.last_name = puv.pc_last_name,
                    dw.email = puv.email,
                    dw.phone = puv.phone;
                    
    --update current customers
merge into client_dw dw
    using curr_user_view cuv
    on (dw.client_id = cuv.user_id and dw.data_source = 'CURR')
when matched then 
    update set  dw.first_name = cuv.first_name, 
                dw.last_name = cuv.last_name,
                dw.email = cuv.email,
                dw.phone = cuv.phone;
    

--Inserting new, making a procedure
create or replace procedure client_etl_proc as 

begin
    --insert new prospective customers
    insert into client_dw
    select puv.data_source, puv.prospective_id, 
        puv.pc_first_name as first_name, 
        puv.pc_last_name as last_name,
        puv.email as email,
        puv.phone as phone
    from prospective_user_view puv left join client_dw dw
        on puv.prospective_id = dw.client_id 
        and puv.data_source = dw.data_source
    where dw.client_id is null
    ;
    
    --insert new current customers
    insert into client_dw
    select cuv.data_source, cuv.user_id, 
        cuv.first_name as first_name, 
        cuv.last_name as last_name,
        cuv.email as email,
        cuv.phone as phone
    from curr_user_view cuv left join client_dw dw
        on cuv.user_id = dw.client_id 
        and cuv.data_source = dw.data_source
    where dw.client_id is null
    ;
    
    --update prospective customers
    merge into client_dw dw
        using prospective_user_view puv
        on (dw.client_id = puv.prospective_id and dw.data_source = 'PROS')
    when matched then 
        update set  dw.first_name = puv.pc_first_name, 
                    dw.last_name = puv.pc_last_name,
                    dw.email = puv.email,
                    dw.phone = puv.phone;
                    
    --update current customers
    merge into client_dw dw
        using curr_user_view cuv
        on (dw.client_id = cuv.user_id and dw.data_source = 'CURR')
    when matched then 
        update set  dw.first_name = cuv.first_name, 
                    dw.last_name = cuv.last_name,
                    dw.email = cuv.email,
                    dw.phone = cuv.phone;
    
end;
/
