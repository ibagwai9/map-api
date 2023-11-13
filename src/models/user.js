module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define(
    "User",
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      name: DataTypes.STRING,
      username: DataTypes.STRING,
      email: DataTypes.STRING,
      password: DataTypes.STRING,
      role: DataTypes.STRING,
      taxID: DataTypes.STRING,
      account_type: DataTypes.STRING,
      phone: DataTypes.STRING,
      accessTo: DataTypes.STRING,
      mda_name: DataTypes.STRING,
      mda_code: DataTypes.STRING,
      department: DataTypes.STRING,
      rank: DataTypes.STRING,
      createdAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
      },
      updatedAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
        onUpdate: DataTypes.NOW,
      },
    },
    {
      tableName: "users",
      timestamps: false,
    }
  );

  User.associate = function (models) {
    // associations go here
  };

  return User;
};
