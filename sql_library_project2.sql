--library project for sql--

--create table for branch--

drop table if exists branch;
create table branch
          (
		    branch_id varchar(10) primary key,
			manager_id varchar(10),	
			branch_address varchar(55),
			contact_no varchar(10)
          );
alter table branch
alter column contact_no type varchar(20)
		  select * from branch

---create table for employees--

drop table if exists employee;
create table employee
          (
             emp_id	varchar(10) primary key,
			 emp_name varchar(25),
			 position varchar(15),	
			 salary	int, 
			 branch_id varchar(25)
          );
		  alter table employee
		  alter column salary type varchar(30)

		  select * from employee

---cretae table for books--

create table books
          ( 
		    isbn varchar(20) PRIMARY KEY,	
		    book_title varchar(75),
		    category varchar(10),
		    rental_price float,
		    status varchar(15),
		    author	varchar(35),
		    publisher varchar(55)
          );
alter table books
		  alter column category type varchar(20)

		   select * from employee

---cretae table for memebers--

create table members
           (
             member_id	varchar(20) PRIMARY KEY,
			 member_name	varchar(20),
			 member_address	varchar(75),
			 reg_date date
           )
		   select * from members

---create table for issued_table---

create table issued_table
		   (
             issued_id	varchar(10) PRIMARy KEY,
			 issued_member_id	varchar(10),
			 issued_book_name	varchar(75),
			 issued_date	date,
			 issued_book_isbn	varchar(25),
			 issued_emp_id varchar(10)

		   )

---create table for return_status--

create table return_status
           (
            return_id	varchar(10) PRIMARY KEY,
			issued_id	varchar(10),
			return_book_name	varchar(75),
			return_date	date,
			return_book_isbn varchar(20)

		   )