select * from portfolio..[Nashville Housing];

-- changing dagte format

select SaleDate, convert(date,SaleDate) from Portfolio..[Nashville Housing];

Alter table [Nashville Housing]
add SaleDateconverted date;

update [Nashville Housing]
set SaleDateconverted = convert(date,SaleDate);

select SaleDateconverted, convert(date,SaleDate) from Portfolio..[Nashville Housing];

-- update propert address

select * from portfolio..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress )
from portfolio.dbo.[Nashville Housing] a
join portfolio.dbo.[Nashville Housing] b
on a.ParcelID= b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress )
from portfolio.dbo.[Nashville Housing] a
join portfolio.dbo.[Nashville Housing] b
on a.ParcelID= b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- separate address with delimeter

select SUBSTRING(PropertyAddress,1, charindex(',' , PropertyAddress) -1) as Address ,
SUBSTRING(PropertyAddress, charindex(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from
portfolio.dbo.[Nashville Housing];


Alter table [Nashville Housing]
add PropertySplitAddress nvarchar(255);

update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, charindex(',' , PropertyAddress) -1);

Alter table [Nashville Housing]
add PropertycityAddress nvarchar(255);

update [Nashville Housing]
set PropertycityAddress = SUBSTRING(PropertyAddress, charindex(',' , PropertyAddress) +1 , LEN(PropertyAddress));

select* from Portfolio..[Nashville Housing];

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from Portfolio..[Nashville Housing];

Alter table [Nashville Housing]
add OwnerSplitAddress nvarchar(255);

update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3);

Alter table [Nashville Housing]
add OwnerCityAddress nvarchar(255);

update [Nashville Housing]
set OwnerCityAddress = PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter table [Nashville Housing]
add OwnerStateAddress nvarchar(255);

update [Nashville Housing]
set OwnerStateAddress = PARSENAME(Replace(OwnerAddress,',','.'),1);

select * from portfolio..[Nashville Housing];

--Replace Y & N with yes and NO

select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant),
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End
from Portfolio..[Nashville Housing]
group by SoldAsVacant
order by 2;

update [Nashville Housing]
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End

-- Remove unused and duplicate data

Select *
from Portfolio..[Nashville Housing];

with rownum_cte as (Select * , ROW_NUMBER() over(partition by ParcelId,PropertyAddress,
SalePrice,SaleDate,LegalReference order by UniqueId  ) as Row_num
from Portfolio..[Nashville Housing])
select * from rownum_cte
where Row_num >1;

alter table Portfolio..[Nashville Housing]
drop column PropertyAddress,OwnerAddress,SaleDate;