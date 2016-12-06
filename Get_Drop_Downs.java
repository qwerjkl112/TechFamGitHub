package hellow;

import java.sql.*;
import javax.sql.*;
import java.util.HashMap;
import java.util.ArrayList;

public class Get_Drop_Downs {
	// Database information
	private final String DATABASE_NAME = "techfam";
	private final String DATABASE_USERNAME = "root";
	private final String DATABASE_PASSWORD = "noclown1";
	private final String DATABASE_CONNECT_STRING = "jdbc:mysql://localhost:3306/" + DATABASE_NAME + 
				"?autoReconnect=true&useSSL=false";
	
	String category_sql = 	"SELECT DISTINCT C2.category_name, C4.category_name, C4.category_id " +
			"FROM category C1, category C2, category C3, category C4 " +
			"WHERE C1.parent_id IS NULL AND " +
			"C2.parent_id = C1.category_id AND " + 
			"C3.parent_id = C2.category_id AND " +
			"C4.parent_id = C3.category_id";
	
	public HashMap<Integer, String> get_addresses(int supplier_id) throws SQLException{
		
		String address_sql = "SELECT address_id, street_address FROM address where supplier_id = ?";
		HashMap<Integer, String> address = new HashMap<Integer, String>();

		Connection con = null;
		PreparedStatement select_address;
		ResultSet result_address;

		try{
			con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
			
			select_address = con.prepareStatement(address_sql);
			select_address.setInt(1, supplier_id);
			result_address = select_address.executeQuery();
			
			while(result_address.next()){
				address.put(result_address.getInt(1), result_address.getString(2));
			}
			
		}catch(Exception e){
			try{
				if(con != null){
					con.rollback();
				}
			}catch(Exception e2){}
		}finally{
			if(con != null){
				con.close();
			}
		}
		
		return address;
	}
	
	public HashMap<Long, String> get_credit_cards(String username) throws SQLException{
		
		String credit_sql = "SELECT number FROM credit_card where username = ?";
		HashMap<Long, String> credit = new HashMap<Long, String>();
		Long number;
		String special_number;
		
		Connection con = null;
		PreparedStatement select;
		ResultSet result;

		try{
			con = DriverManager.getConnection(DATABASE_CONNECT_STRING, DATABASE_USERNAME, DATABASE_PASSWORD);
			
			select = con.prepareStatement(credit_sql);
			select.setString(1, username);
			result = select.executeQuery();
			
			while(result.next()){
				number = result.getLong(1);
				special_number = number.toString();
				special_number = "************" + special_number.substring(special_number.length()-4);
				credit.put(number, special_number);
			}
			
		}catch(Exception e){
			try{
				if(con != null){
					con.rollback();
				}
			}catch(Exception e2){}
		}finally{
			if(con != null){
				con.close();
			}
		}
		
		return credit;
	}
	
}
