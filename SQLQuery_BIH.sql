/*Thiết kế câu lệnh truy vấn
	1. Quản lý thông tin bệnh nhân*/

USE BIH_DATABASE
-- Thống kê danh sách bệnh nhân
IF OBJECT_ID ('Patient_list', 'V') IS NOT NULL
	DROP VIEW Patient_list
GO

CREATE VIEW Patient_list AS
SELECT Patient_id AS N'Mã bệnh nhân', Patient_name AS N'Họ và tên'
FROM Patient
GO

SELECT * FROM Patient_list

--Thống kê bệnh nhân theo điều kiện
--Vd1. Thống kê danh sách bệnh nhân có giới tính Nam
IF OBJECT_ID ('Patient_list_dk1', 'V') IS NOT NULL
	DROP VIEW Patient_list_dk1
GO

CREATE VIEW Patient_list_dk1 AS
SELECT Patient_id AS N'Mã bệnh nhân', Patient_name AS N'Họ và tên'
FROM Patient
WHERE PSex = 'M'
GO

SELECT * FROM Patient_list_dk1

--Vd2. Thống kê danh sách bệnh nhân ở Thành phố Hồ Chí Minh
IF OBJECT_ID ('Patient_list_dk2', 'V') IS NOT NULL
	DROP VIEW Patient_list_dk2
GO

CREATE VIEW Patient_list_dk2 AS
SELECT Patient_id AS N'Mã bệnh nhân', Patient_name AS N'Họ và tên'
FROM Patient
WHERE Province LIKE N'%TP.Hồ Chí Minh%'
GO

SELECT * FROM Patient_list_dk2

--Hiển thị thông tin cá nhân của một bệnh nhân <proc>
IF OBJECT_ID ('sp_Patient_info', 'P') IS NOT NULL
	DROP PROCEDURE sp_Patient_info
GO

CREATE PROCEDURE sp_Patient_info 
	@Patient_id VARCHAR(10)
AS
	IF (NOT EXISTS (SELECT * FROM Patient p WHERE p.Patient_id = @Patient_id))
		BEGIN
			RAISERROR('Not a valid PATIENT ID',11,1)
		END
	ELSE 
		BEGIN
	SELECT p.Patient_id AS N'Mã bệnh nhân', p.Patient_name AS N'Họ và tên', CASE WHEN p.PSex ='F' THEN N'Nữ' ELSE N'Nam' END AS N'Giới tính', p.PBirthdate AS N'Ngày sinh', YEAR(GETDATE()) - YEAR(p.PBirthdate) AS N'Tuổi', p.AddressNum AS N'Số nhà', p.Ward AS N'Phường', p.Province AS N'Tỉnh', p.PPhone AS N'SĐT', p.PEmail AS 'Email'
	FROM Patient p
	WHERE p.Patient_id = @Patient_id
		END
GO

EXEC sp_Patient_info '2023000018';
GO

--Hiển thị thông tin cá nhân của một bệnh nhân <VIEW>
IF OBJECT_ID ('Patient_info', 'V') IS NOT NULL
	DROP VIEW Patient_info
GO

CREATE VIEW Patient_info AS
SELECT p.Patient_id AS N'Mã bệnh nhân', p.Patient_name AS N'Họ và tên', CASE WHEN p.PSex ='F' THEN N'Nữ' ELSE N'Nam' END AS 
	N'Giới tính', p.PBirthdate AS N'Ngày sinh', YEAR(GETDATE()) - YEAR(p.PBirthdate) AS N'Tuổi', p.AddressNum AS N'Số nhà', 
	p.Ward AS N'Phường', p.Province AS N'Tỉnh', p.PPhone AS N'SĐT', p.PEmail AS 'Email'
FROM Patient p
WHERE P.Patient_id = '2023000018'
GO

SELECT * FROM Patient_info 

--Thêm bệnh nhân proc
IF OBJECT_ID ('sp_Insert_Patient', 'P') IS NOT NULL
	DROP PROCEDURE sp_Insert_Patient
GO

CREATE PROCEDURE sp_Insert_Patient
	@Patient_id VARCHAR(10),
	@Patient_name Nvarchar(50),
	@PSex Char(1),
	@PBirthdate Date,
	@AddressNum varchar(30),
	@Ward Nvarchar(30),
	@District Nvarchar(30),
	@Province Nvarchar(30),
	@PPhone Varchar(10),
	@PEmail Varchar(50)
AS
	IF (EXISTS (SELECT * FROM Patient p WHERE p.Patient_id = @Patient_id))
		BEGIN
			RAISERROR('This patient_id already exists',11,1)
		END
	ELSE 
		BEGIN
			INSERT INTO Patient VALUES (@Patient_id, @Patient_name, @PSex, @PBirthdate, @AddressNum, @Ward, @District, @Province, @PPhone, @PEmaiL);
		END
GO

EXEC sp_Insert_Patient '2023000018', N'Phạm Ngọc Minh Thư', 'F', '11/25/2002', '1020/52', N'Chánh Nghĩa', N'Thủ Dầu Một', N'Bình Dương', '0943821360', 'Thu25112002@gmail.com';
GO
EXEC sp_Insert_Patient '2023000019', N'Trương Thị Minh Châu', 'F', '02/13/2002', '39 Phạm Ngũ Lão', N'Phú Cường', N'Thủ Dầu Một', N'Bình Dương', '0355554808', 'Minhchau@gmail.com';
GO


--Thêm BHYT
IF OBJECT_ID ('sp_Insert_Insurrance', 'P') IS NOT NULL
	DROP PROCEDURE sp_Insert_Insurrance
GO

CREATE PROCEDURE sp_Insert_Insurrance 
	@Insurance_id Decimal(18,0),
	@Publish_date DATE,
	@Expire_date DATE,
	@Percen INT,
	@Patient_id VARCHAR(10)
AS	
	IF (NOT EXISTS (SELECT * FROM Patient p WHERE p.Patient_id = @Patient_id))
		BEGIN
			RAISERROR('Not a valid PATIENT ID',11,1)
		END
	ELSE 
		BEGIN
	INSERT INTO Insurance VALUES (@Insurance_id, @Publish_date, @Expire_date, @Percen, @Patient_id)
		END
GO

EXEC sp_Insert_Insurrance '2893082418563', '09/19/2021', '09/19/2025',80,'2023000018';
GO
EXEC sp_Insert_Insurrance '1849257693813', '09/19/2021', '09/19/2025',80,'2023000019';
GO


--Chỉnh sửa thông tin bệnh nhân proc
--VD1. Đổi tên bệnh nhân
IF OBJECT_ID ('sp_Change_Patient_Name', 'P') IS NOT NULL
	DROP PROCEDURE sp_Change_Patient_Name
GO

CREATE PROCEDURE sp_Change_Patient_Name 
	@Patient_id VARCHAR(10),
	@Name NVARCHAR(50)
AS
	IF (NOT EXISTS (SELECT * FROM Patient p WHERE p.Patient_id = @Patient_id))
		BEGIN
			RAISERROR('Not a valid PATIENT ID',11,1)
		END
	ELSE 
		BEGIN
			UPDATE Patient
			SET Patient_name = @Name
			WHERE Patient_id = @Patient_id
		END
GO

EXEC sp_Change_Patient_Name '2023000018', N'Phạm Ngọc Minh Thư';
EXEC sp_Patient_info '2023000018';
GO

--4. Quản lý thông tin bác sĩ
--Thống kê bác sĩ tương tự như với bệnh nhân
--Thêm bác sĩ
--Tạo Trigger cho bác sĩ phải từ đủ 26 đến dưới 65
CREATE TRIGGER DoctorAgeTrigger
ON DOCTOR AFTER INSERT
AS
DECLARE @Age INT
SELECT @Age=YEAR(d.DBirthdate) FROM Doctor d JOIN inserted i ON d.Doctor_id = i.Doctor_id
IF YEAR(GETDATE()) - @Age < 26 OR YEAR(GETDATE()) - @Age > 65
	BEGIN 
		RAISERROR ('This doctor is not between 26 and 65 years old. We cannot sign a contact with him/her', 16,1)
		ROLLBACK TRANSACTION 
	END
GO

INSERT INTO Doctor (Doctor_id, Doctor_name, DSex, DBirthdate, AddressNum, Ward, District, Province, DPhone, DEmail, DSalary, DPosition, DFaculty_id)
	VALUES 
	('10022', N'Nguyễn Văn An', 'M', '08/03/2010', '19A', N'Phú Cường', N'Thủ Dầu Một', N'Bình Dương', '0912345678', 'NguyenVanA@gmail.com', 31000, N'Chuyên khoa Xét nghiệm',1)

--Xóa bác sĩ
IF OBJECT_ID ('sp_Delete_Doctor', 'P') IS NOT NULL
	DROP PROCEDURE sp_Delete_Doctor
GO

CREATE PROCEDURE sp_Delete_Doctor
	@Doctor_id VARCHAR(10)
AS
	IF (NOT EXISTS (SELECT * FROM Doctor d WHERE d.Doctor_id = @Doctor_id))
		BEGIN
			RAISERROR('Not a valid DOCTOR ID',11,1)
		END
	ELSE 
		BEGIN
			DELETE FROM Doctor 
			WHERE Doctor_id = @Doctor_id
		END
GO

EXEC sp_Delete_Doctor '10019'
GO

--5 Quản lý thông tin thuốc 
IF OBJECT_ID ('Medication_list', 'V') IS NOT NULL
	DROP VIEW Medication_list
GO

CREATE VIEW Medication_list AS
SELECT m.Medication_id AS N'Mã thuốc', m.Branch_name AS N'Tên biệt dược', m.Chemical_name AS N'Tên hoạt chất', m.Med_unit AS N'Đơn vị', m.Med_desc AS N'Mô tả', s.Supplier_name AS N'Nhà cung cấp'
FROM Medication m JOIN Supplier s ON m.Med_supplier_id = s.Supplier_id 
GO

SELECT * FROM Medication_list

use BIH_DATABASE
 
--6. Quản lý thông tin tài chính
--Hàm thống kê doanh thu thuốc theo năm với tham số truyền vào là tháng
CREATE fUNCTION fun_Medication_Month (@Month INT)
RETURNS INT
AS	
	BEGIN
		RETURN (
			SELECT SUM(m.Med_price*p.Quanity) 
			FROM Pres_Detail p JOIN Medication m ON p.Medication_id = m.Medication_id
			WHERE Month(p.Create_date) = @Month 
			GROUP BY p.Create_date)
	END
GO
SELECT dbo.fun_Medication_Month (4) AS N'Doanh thu thuốc'

---Lấy ra top 5 loại thuốc có doanh thu tốt nhất của tháng
CREATE fUNCTION fun_Medication_Top5 (@Month INT)
RETURNS TABLE RETURN
		SELECT TOP(5) m.Medication_id AS N'Mã thuốc', m.Chemical_name AS N'Tên hoạt chất', SUM(m.Med_price*p.Quanity) AS N'Doanh thu'
		FROM Pres_Detail p JOIN Medication m ON p.Medication_id = m.Medication_id 
		WHERE Month(p.Create_date) = @Month
		GROUP BY m.Medication_id, m.Chemical_name
		Order by SUM(m.Med_price*p.Quanity) DESC
GO
drop function dbo.fun_Medication_Top5
SELECT * from dbo.fun_Medication_Top5 (4) 
--Hàm tính tổng số tiền đã đóng cho bệnh viện với tham số truyền vào là mã bệnh nhân
---Chi phí dịch vụ
IF OBJECT_ID ('fun_Service_Charge', 'FN') IS NOT NULL
	DROP FUNCTION fun_Service_Charge
GO

CREATE fUNCTION fun_Service_Charge (@Patient_id VARCHAR(10))
RETURNS INT
AS	
	BEGIN
		DECLARE @Service_charge INT
		IF (NOT EXISTS (SELECT * FROM Service_Using s WHERE s.Patient_id = @Patient_id))
			RETURN 0 
		ELSE
		SET @Service_charge = (SELECT SUM(s.Ser_price) 
			FROM Service s , Service_Using su
			WHERE s.Service_id = su.Service_id AND su.Patient_id = @Patient_id 
			GROUP BY su.Patient_id)
		RETURN @Service_charge
	END
GO
select dbo.fun_Service_Charge ('2023000018') AS N'Chi phí dịch vụ'

---Chi phí thuốc
IF OBJECT_ID ('fun_Medication_Charge', 'FN') IS NOT NULL
	DROP FUNCTION fun_Medication_Charge
GO

CREATE fUNCTION fun_Medication_Charge (@Patient_id VARCHAR(10))
RETURNS INT
AS
	BEGIN
		DECLARE @Medication_charge INT
		IF (NOT EXISTS (SELECT * FROM Prescription p WHERE p.Pres_patient_id = @Patient_id))
			RETURN 0
		ELSE
		SET @Medication_charge = (SELECT SUM(m.Med_price*pd.Quanity) 
			FROM Medication m , Pres_Detail pd, Prescription p 
			WHERE m.Medication_id = pd.Medication_id AND p.Pres_patient_id = @Patient_id AND P.Prescription_id = pd.Prescription_id
			GROUP BY p.Pres_patient_id)
		RETURN @Medication_charge
	END
GO
select dbo.fun_Medication_Charge('2023000018') AS N'Chi phí thuốc'

---Chi phí nằm giường
IF OBJECT_ID ('fun_Stay_Charge', 'FN') IS NOT NULL
	DROP FUNCTION fun_Stay_Charge
GO

CREATE fUNCTION fun_Stay_Charge (@Patient_id VARCHAR(10))
RETURNS INT
AS
	BEGIN
		DECLARE @Room_charge INT
		IF (NOT EXISTS (SELECT * FROM Stay s WHERE s.Patient_id = @Patient_id))
			RETURN 0
		ELSE
		SET @Room_charge = (SELECT SUM(rm.Room_price*(DATEDIFF(day, s.Begin_date, S.End_date))) 
			FROM Room_Categories rm, Room r, Bed b, Stay s
			WHERE rm.Room_categories_id = r.Room_categories_id 
				AND	r.Room_id = b.Room_id 
				AND b.Bed_id = s.Bed_id 
				AND s.Patient_id = @Patient_id
			GROUP BY s.Patient_id)
		RETURN @Room_charge
	END
GO

----Tổng chi phí
IF OBJECT_ID ('sp_Patient_charge', 'P') IS NOT NULL
	DROP PROCEDURE sp_Patient_charge
GO

CREATE PROCEDURE sp_Patient_charge
	@Patient_id VARCHAR(10)
AS
	IF (NOT EXISTS (SELECT * FROM Patient p WHERE p.Patient_id = @Patient_id))
		BEGIN
			RAISERROR('Not a valid PATIENT ID',11,1)
		END
	ELSE 
		BEGIN
	SELECT p.Patient_name AS N'Họ và tên', CASE WHEN p.PSex ='F' THEN N'Nữ' ELSE N'Nam' END AS N'Giới tính', 
		YEAR(GETDATE()) - YEAR(p.PBirthdate) AS N'Tuổi',
		dbo.fun_Service_Charge (@Patient_id) AS N'Chi phí dịch vụ',
		dbo.fun_Medication_Charge(@Patient_id) AS N'Chi phí thuốc', 
		dbo.fun_Stay_Charge(@Patient_id) AS N'Chi phí nằm giường'
	FROM Patient p
	WHERE p.Patient_id = @Patient_id
		END
GO

EXEC sp_Patient_charge'2023000018';
GO
SELECT dbo.fun_Service_Charge('2023000018') AS N'Chi phí dịch vụ'

--Quản lý bệnh án
IF OBJECT_ID ('fun_1', 'FN') IS NOT NULL
	DROP FUNCTION fun_1
GO

CREATE fUNCTION fun_1 (@Patient_id VARCHAR(10))
RETURNS table return
		Select	f.Create_date AS N'Ngày khám', i.Patient_id AS N'Mã bệnh nhân', i.Patient_name AS N'Họ và tên', CASE WHEN i.PSex ='F' THEN N'Nữ' 
				ELSE N'Nam' END AS N'Giới tính', YEAR(GETDATE()) - YEAR(i.PBirthdate) AS N'Tuổi', i.Province AS N'Tỉnh', i.PPhone AS N'SĐT', 
				f.Clinic_id AS N'Phòng khám', d.Doctor_name AS N'Bác sĩ phụ trách', CASE WHEN f.Patient_type ='1' THEN N'Có BHYT' 
				ELSE N'Không BHYT' END AS N'Đối tượng', f.Diagnose AS N'Chẩn đoán'
		FROM Patient i JOIN Patient_flow f ON i.Patient_id = f.Patient_id
			JOIN Doctor d ON d.Doctor_id = f.Doctor_id 
			AND i.Patient_id = @Patient_id
GO


IF OBJECT_ID ('fun_2', 'FN') IS NOT NULL
	DROP FUNCTION fun_2
GO

CREATE fUNCTION fun_2 (@Patient_id VARCHAR(10))
RETURNS table return
		SELECT s.Service_name AS N'Các xét nghiệm', su.Blood_pressure AS N'Chỉ số huyết áp', su.Weight AS N'Cân nặng',
			su.Height AS N'Chiều cao', d.Doctor_name AS N'Bác sĩ thực hiện', su.Test_result AS N'Kết quả'
		FROM Service s JOIN Service_Using su ON s.Service_id = su.Service_id 
			JOIN Patient i ON su.Patient_id = i.Patient_id
			JOIN Doctor d ON su.Test_doctor_id = d.Doctor_id
			AND i.Patient_id = @Patient_id
GO

IF OBJECT_ID ('fun_3', 'FN') IS NOT NULL
	DROP FUNCTION fun_3
GO

CREATE fUNCTION fun_3 (@Patient_id VARCHAR(10))
RETURNS table return
		SELECT m.Chemical_name AS N'Thuốc đã dùng', pd.Quanity AS N'Số lượng'
		FROM Patient i JOIN Prescription p ON i.Patient_id = p.Pres_patient_id
			JOIN Pres_Detail pd ON pd.Prescription_id = P.Prescription_id
			JOIN Medication m ON m.Medication_id = pd.Medication_id
			AND i.Patient_id = @Patient_id
GO
select * from dbo.fun_3('2023000018');

----------Tạo proc
IF OBJECT_ID ('sp_Patient_Report', 'P') IS NOT NULL
	DROP PROCEDURE sp_Patient_Report
GO

CREATE PROCEDURE sp_Patient_Report
	@Patient_id VARCHAR(10)
AS
	IF (NOT EXISTS (SELECT * FROM Patient p WHERE p.Patient_id = @Patient_id))
		BEGIN
			RAISERROR('Not a valid PATIENT ID',11,1)
		END
	ELSE 
		BEGIN
			SELECT * FROM dbo.fun_1(@Patient_id)
			SELECT * FROM dbo.fun_2(@Patient_id)
			SELECT * FROM dbo.fun_3(@Patient_id)
		END
GO
EXEC sp_Patient_Report '2023000018';
GO

-------------------------------------
--BACKUP
BACKUP DATABASE [BIH_DATABASE] TO DISK = N'C:\data\BIH_FullBK.BAK'
WITH NOFORMAT, NOINIT,
NAME = N'BIH-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO

BACKUP DATABASE [BIH_DATABASE] TO DISK = N'C:\data\BIH_DiffBK.BAK'
WITH DIFFERENTIAL, NOFORMAT, NOINIT,
NAME = N'BIH-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO

BACKUP LOG [BIH_DATABASE] TO DISK = N'C:\data\BIH_LogBK.BAK'
WITH NOFORMAT, NOINIT,
NAME = N'BIH-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO



