select * from books
select * from branch
select * from employee
select * from issued_table
select * from members
select * from return_status



--- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

---Task 2: Update an Existing Member's Address--
update members
set member_address ='777 Oak st'
where member_id = 'C103';

--- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_table
where issued_id = 'IS121';

---Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_table
where issued_emp_id = 'E101';

---List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select 
       issued_emp_id,
	   count(*)
	   from issued_table
	   group by 1
	   having  count(*)>1;

--3. CTAS (Create Table As Select)

---Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
select b.isbn,
b.book_title,
count(ist.issued_id)as no_of_issued_book
from books as b
join
issued_table as ist
on ist.issued_book_isbn = b.isbn
group by 1

--4. Data Analysis & Findings
--The following SQL queries were used to address specific questions:

---Task 7. Retrieve All Books in a Specific Category:
select * from books
where category ='Classic'

---Task 8: Find Total Rental Income by Category:

select
b.category,
sum(b.rental_price)as rental_income,
count(*)
from books as b
join
issued_table as ist
on ist.issued_book_isbn = b.isbn
group by 1

--Task 9.List Members Who Registered in the Last 180 Days:
select * from members
where reg_date >= current_date - interval '180 days'

insert into members(member_id,member_name,member_address,reg_date)
values
('C122','alisha boderland','jullie vale','2025-05-03'),
('C125','jinny boderland','jullie vale','2025-05-03');

---Task 10.List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employee as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employee as e2
ON e2.emp_id = b.manager_id

---Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

create table expensive_books as
select * from books
where rental_price > 7.00;
select * from expensive_books

--Task 12: Retrieve the List of Books Not Yet Returned

select DISTINCT issued_book_name
from issued_table as ist
left join
return_status as rs
on rs.issued_id = ist.issued_id
where rs.issued_id IS NULL;

--ADVANCED SQL
--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

select 
ist.issued_member_id,
m.member_name,
bk.book_title,
ist.issued_date,
--rs.return_date,
current_date - ist.issued_date as over_dues_days
from issued_table as ist
join
members as m
on m.member_id = ist.issued_member_id
join
books as bk
on bk.isbn=ist.issued_book_isbn
left join
return_status as rs
on rs.issued_id = ist.issued_id
where rs.return_date is null
order by 1

--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

--stored procedure
create or replace procedure add_return_records(p_return_id varchar(10),p_issued_id  varchar(10),p_book_quality varchar(15))
language plpgsql
as $$

declare
v_isbn varchar(50);
v_book_name varchar(50);
begin

insert into return_status(return_id,issued_id,return_date,book_quality)
values
(p_return_id,issued_id,CURRENT_DATE,p_book_quality);

select
issued_book_isbn,
issued_book_name,
into
v_isbn
v_book_name
from issued_status
where issued_id = p_issued_id ;

update books
set status = 'yes'
where isbn = v_isbn;

raise notice 'thank you returning the book: %',v_book_name;

end;
$$
call add_return_records()

--testing function add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_table
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
select * from books
select * from branch
select * from employee
select * from return_status
select * from issued_table

create table branch_report
as
select 
b.branch_id,
b.manager_id,
sum(rental_price)as total_revenue,
count(ist.issued_id)as number_of_book_issued,
count(rs.return_id)as number_of_book_return
from issued_table as ist
join
employee as emp
on emp.emp_id = ist.issued_emp_id
join
branch as b
on b.branch_id = emp.branch_id
left join
return_status as rs
on rs.issued_id = ist.issued_id
join
books as bk
on ist.issued_book_isbn = bk.isbn
group by 1,2;

--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

create table active_member
as
select * from members
where member_id in (select 
                distinct issued_member_id
                from issued_table
                where issued_date >=  current_date - interval '2 month' 
				)

--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select 
emp.emp_name,
b.*,
count(ist.issued_id) as no_book_issued
from issued_table as ist
join
employee as emp
on emp.emp_id = ist. issued_emp_id
join
branch as b
on b.branch_id = emp.branch_id
group by 1,2;

/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/

select * from books
select * from issued_table

create or replace procedure issued_book(p_issued_id varchar(10),p_issued_member_id varchar(10),p_issued_book_isbn varchar(25),
p_issued_emp_id varchar(10))

language plpgsql
as $$

declare
--all the variables
v_status varchar(10);
begin
--all the code
--checking if book is available 'yes'
select
status 
into
v_status
from books
where isbn=p_issued_book_isbn;

if v_status = 'yes' then

insert into issued_table(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
values
(p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id );

update books
set status = 'no'
where isbn = p_issued_book_isbn;

RAISE NOTICE 'BOOK RECORD ADDED SUCCESFULLY FOR BOOK ISBN : %',p_issued_book_isbn;

else

RAISE NOTICE 'sorry to inform you that the book is unavailable BOOK ISBN : %',p_issued_book_isbn;

end if;
end;
$$

select *  from books
--"978-0-375-41398-8"--no
--"978-0-553-29698-2"--yes
select * from issued_table

call issued_book('IS155','C108','978-0-553-29698-2','E104');