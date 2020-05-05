-- create database
create database ooo;

use ooo;
-- create tables

CREATE TABLE user (
	id INT AUTO_INCREMENT,
	user_name varchar(100),
	preferred_name varchar(100),
	password varchar(100),
	email varchar(100),
	last_logindatetime datetime,
	creation_dateandtime datetime,
	birthday date COMMENT 'for presents!',
	phone_number INT COMMENT 'for resets!',
	PRIMARY KEY (id)
);


CREATE TABLE bank (
	id int,
	name varchar(100),
	headquarters_address varchar(100),
	PRIMARY KEY (id)
);

CREATE TABLE branch (
	id INT,
	bank_id int,
	postal_code varchar(100),
	address varchar(100),
	is_central varchar(100),
	PRIMARY KEY (id),
	FOREIGN KEY fk_branch (bank_id) REFERENCES bank (id) ON DELETE CASCADE
);

CREATE TABLE account (
	id INT,
	nick_name varchar(100),
	account_id varchar(100),
	branch_id INT,
    user_1 int,
    user_2 int,
	type varchar(100),
	PRIMARY KEY (id),
	FOREIGN KEY fk_account (branch_id) REFERENCES branch (id) ON DELETE CASCADE,
    FOREIGN KEY fk_account_user_1(user_1) REFERENCES user(id) ON DELETE CASCADE,
    FOREIGN KEY fk_account_user_2(user_2) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE category (
	id INT AUTO_INCREMENT,
	user_id INT,
	description varchar(100),
	PRIMARY KEY (id),
	FOREIGN KEY fk_category (user_id) REFERENCES user (id) ON DELETE CASCADE
);

CREATE TABLE transaction (
	id INT,
	account_id int,
	merchant varchar(100),
	category_id INT,
	description varchar(100),
	transaction_datetime datetime,
	clearing_datetime datetime,
	amount float,
	PRIMARY KEY (id),
	FOREIGN KEY fk_trans_account (account_id) REFERENCES account (id) ON DELETE CASCADE,
	FOREIGN KEY fk_trans_category (category_id) REFERENCES category (id)
);

CREATE TABLE error (
	id INT,
	error_datetime datetime,
	account_id int,
	message varchar(100),
	PRIMARY KEY (id),
	FOREIGN KEY fk_error (account_id) REFERENCES account (id) ON DELETE CASCADE
);

-- create triggers
delimiter $
create trigger t_updatetransaction1 
before insert on transaction
for each row
begin
if (NEW.clearing_datetime < NEW.transaction_datetime) then 
    signal sqlstate '45000' set message_text = 'clearing time must greater than transaction time!';
END IF;
End $
DELIMITER ;


-- insert example  records

insert into user values(1,'Abbott','Abbott','124','2@gamil.com',now(),'2019-11-19 17:11:10','1991-07-22','222222');
insert into user values(2,'Lily','Lily','4374822','2@gamil.com',now(),'2019-11-19 17:11:10','1991-07-22','222222');

insert into bank values(1,'A bank','a road BA1 UK1');
insert into bank values(2,'B bank','a road BA1 UK1');

insert into branch values(801,1,'SA1 UK2','old cut road','NO');
insert into branch values(802,2,'SA1 UK2','old cut road','YES');

insert into account values(1,'009','11827211122',801,1,2,'savings');
insert into account values(2,'010','26238472872',802,2,null,'current');
insert into account values(3,'010','26238472872',802,2,null,'loan');

insert into category values(101,null,'food');
insert into category values(102,null,'pets');
insert into category values(103,null,'kids');
insert into category values(104,null,'bills');
insert into category values(105,1,'trip');

insert into transaction values(1,1,'TESCO',101,'rents',now(),'2019-12-13 10:10:19',10);
insert into transaction values(2,2,'TESCO',102,'fee',now(),'2019-12-13 10:10:19',10);
insert into transaction values(3,3,'TESCO',103,'living cost',now(),'2019-12-13 10:10:19',10);


insert into error values(1,now(),1,'frozen');

-- queries
-- Q1&2&3
show tables;
show full columns from account;
show full columns from balance;
show full columns from bank;
show full columns from branch;
show full columns from category;
show full columns from category_amount;
show full columns from error;
show full columns from net_worth;
show full columns from transaction;
show full columns from user;
show create table account;
show create table balance;
show create table bank;
show create table branch;
show create table category;
show create table category_amount;
show create table error;
show create table net_worth;
show create table transaction;
show create table user;
-- 	Q4	
create view balance as select account_id, sum(amount) as balance from transaction group by account_id;
select * from balance;

-- Q5
select bank_id, count(id) as tot_branches from branch group by bank_id;

-- Q6
select b.bank_id, count(a.id) as tot_accounts from account a left join branch b on a.branch_id = b.id group by b.bank_id;

-- Q7
create view net_worth as select b.user_1, sum(a.balance) as equity from balance a left join account b on a.account_id = b.id group by b.user_1;
select * from net_worth where equity = (select max(equity) from net_worth);
select * from net_worth;

-- Q8
select a.id, a.user_1, a.user_2, b.equity as user_1_equity, c.equity as user_2_equity, b.equity - c.equity  from account a, net_worth b, net_worth c  where a.user_2 is not null and a.user_1 = b.user_1 and a.user_2 = c.user_1;

-- Q9
create view category_amount as select b.user_1, a.category_id, sum(a.amount) as tot_amount from transaction a left join account b on a.account_id = b.id group by b.user_1, category_id;
select * from category_amount;
select a.user_1, a.category_id, a.tot_amount from category_amount a, (select user_1, max(tot_amount) as max_amount from category_amount group by user_1) b where a.user_1 = b.user_1 and a.tot_amount = b.max_amount;
