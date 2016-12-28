/*
 * Copyright 2012 LinkedIn Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package azkaban.user;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.log4j.Logger;

import azkaban.database.AbstractJdbcLoader;
import azkaban.user.User.UserPermissions;
import azkaban.utils.Props;

/**
 * Jdbc implementation of the UserManager.
 *
 * Load user information from database via jdbc driver.
 * Using table name is 'users', 'groups','roles'
 */
public class JdbcUserManager extends AbstractJdbcLoader implements UserManager {
  private static final Logger logger = Logger.getLogger(JdbcUserManager.class
      .getName());

  /**
   * The constructor.
   *
   * @param props
   */
  public JdbcUserManager(Props props) {
	  super(props);
  }


  @Override
  public User getUser(String username, String password)
      throws UserManagerException {
    if (username == null || username.trim().isEmpty()) {
      throw new UserManagerException("Username is empty.");
    } else if (password == null || password.trim().isEmpty()) {
      throw new UserManagerException("Password is empty.");
    }

    QueryRunner runner = createQueryRunner();
    FetchUser handler = new FetchUser();
    User user = null;
    try {
    	user = runner.query(FetchUser.FETCH_USER, handler, username, password);
    	if(user != null) {
    		FetchGroupRoles groupHandler = new FetchGroupRoles();
    		for(String group: user.getGroups()) {
    			Set<String> groupRoles = runner.query(FetchGroupRoles.FETCH_GROUP_ROLES, groupHandler, group);
    			if(groupRoles != null) {
    				for(String groupRole: groupRoles) {
    					user.addRole(groupRole);
    				}
    			}
    		}

    		user.setPermissions(new UserPermissions() {
				@Override
				public boolean hasPermission(String permission) {
					return true;
				}
				@Override
				public void addPermission(String permission) {
				}
    		});
    	}
    } catch (SQLException e) {
    	throw new UserManagerException("Error fetch user " + username);
    }
    return user;
  }

  @Override
  public boolean validateUser(String username) {
    if (username == null || username.trim().isEmpty()) {
    	return false;
    }
    
    QueryRunner runner = createQueryRunner();
    ExistUser handler = new ExistUser();
    try {
    	return runner.query(ExistUser.EXIST_USER, handler, username);
    } catch (SQLException e) {}
    
    return false;
  }

  @Override
  public Role getRole(String roleName) {
	if (roleName == null || roleName.trim().isEmpty()) {
		return null;
	}
	
	QueryRunner runner = createQueryRunner();
	FetchRole handler = new FetchRole();
	Role role = null;
	try {
		return runner.query(FetchRole.FETCH_ROLE, handler, roleName);
	} catch (SQLException e) {}

	return role;
  }

  @Override
  public boolean validateGroup(String group) {
	if (group == null || group.trim().isEmpty()) {
		return false;
	}

    QueryRunner runner = createQueryRunner();
	FetchGroupRoles handler = new FetchGroupRoles();
	try {
		if(runner.query(FetchGroupRoles.FETCH_GROUP_ROLES, handler, group) != null) {
			return true;
		}
	} catch (SQLException e) {}
    return false;
  }

  @Override
  public boolean validateProxyUser(String proxyUser, User realUser) {
	if (proxyUser == null || proxyUser.trim().isEmpty()) {
		return false;
    } else if (realUser == null) {
    	return false;
    }
	
	QueryRunner runner = createQueryRunner();
	FetchProxyUser handler = new FetchProxyUser();
	try {
		Set<String> proxySet = runner.query(FetchProxyUser.FETCH_PROXY_USER, handler, realUser.getUserId());
		return proxySet.contains(proxyUser);
	} catch (SQLException e) {}

    return false;
  }
  
  private static class FetchUser implements ResultSetHandler<User> {
	private static String FETCH_USER =
			"SELECT name, roles, groups, email FROM users WHERE name=? AND password=?";
	
	@Override
	public User handle(ResultSet rs) throws SQLException {
		if (!rs.next()) {
			return null;
		}
		
		String userName = rs.getString(1);
		String roles = rs.getString(2);
		String groups = rs.getString(3);
		String email = rs.getString(4);

		User user = new User(userName);
		if(roles != null) {
			String[] roleSplit = roles.split("\\s*,\\s*");
			for (String role : roleSplit) {
				user.addRole(role);
			}
		}
		if(groups != null) {
			String[] groupSplit = groups.split("\\s*,\\s*");
			for (String group : groupSplit) {
				user.addGroup(group);
			}
		}
		if(email != null) {
			user.setEmail(email);
		}

		return user;
	}
  }

  private static class FetchProxyUser implements ResultSetHandler<Set<String>> {
	private static String FETCH_PROXY_USER =
			"SELECT proxy FROM users WHERE name=?";
	
	@Override
	public Set<String>handle(ResultSet rs) throws SQLException {
		if (!rs.next()) {
			return null;
		}
		
		String proxies = rs.getString(1);
		Set<String> proxySet = new HashSet<String>();
		if(proxies != null) {
			String[] proxySplit = proxies.split("\\s*,\\s*");
			for (String proxy: proxySplit) {
				proxySet.add(proxy);
			}
		}

		return proxySet;
	}
  }

  
  private static class ExistUser implements ResultSetHandler<Boolean> {
	  private static String EXIST_USER =
			  "SELECT count(name) FROM users WHERE name=?";

	  @Override
	  public Boolean handle(ResultSet rs) throws SQLException {
		  if (!rs.next()) {
			  return false;
		  }
		  Integer count = rs.getInt(1);
		  return count > 0;
	  }
  }
  
  private static class FetchGroupRoles implements ResultSetHandler<Set<String>> {
	private static String FETCH_GROUP_ROLES =
			"SELECT roles FROM groups WHERE name=?";
	
	@Override
	public Set<String> handle(ResultSet rs) throws SQLException {
		if (!rs.next()) {
			return null;
		}

		String roles = rs.getString(1);

		Set<String> roleSet = new HashSet<String>();
		if(roles != null) {
			String[] roleSplit = roles.split("\\s*,\\s*");
			for (String role : roleSplit) {
				roleSet.add(role);
			}
		}

		return roleSet;
	}
  }

  private static class FetchRole implements ResultSetHandler<Role> {
	private static String FETCH_ROLE =
			"SELECT name, permissions FROM roles WHERE name=?";
	
	@Override
	public Role handle(ResultSet rs) throws SQLException {
		if (!rs.next()) {
			return null;
		}
		
		String roleName = rs.getString(1);
		String permissions = rs.getString(2);
			
		String[] permissionSplit = permissions.split("\\s*,\\s*");

	    Permission perm = new Permission();
	    for (String permString : permissionSplit) {
	      try {
	        Permission.Type type = Permission.Type.valueOf(permString);
	        perm.addPermission(type);
	      } catch (IllegalArgumentException e) {
	        logger.error("Error adding type " + permString
	            + ". Permission doesn't exist.", e);
	      }
	    }
	    
	    Role role = new Role(roleName, perm);
		return role;
	}
  }

}
