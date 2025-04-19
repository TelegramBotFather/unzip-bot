from abc import ABC, abstractmethod


class TableInterface(ABC):
    @abstractmethod
    async def count(self, filter: dict | None = None) -> int:
        """
        Return the count of records matching the filter.
        """
        pass

    @abstractmethod
    async def find_one(self, query: dict) -> dict | None:
        """
        Find and return a single record matching the query.
        """
        pass

    @abstractmethod
    async def get_all(self) -> list:
        """
        Retrieve all records from the table.
        """
        pass

    @abstractmethod
    async def insert(self, document: dict) -> None:
        """
        Insert a new record into the table.
        """
        pass

    @abstractmethod
    async def update(self, query: dict, update: dict) -> None:
        """
        Update record(s) matching the query.
        """
        pass

    @abstractmethod
    async def delete(self, query: dict) -> None:
        """
        Delete record(s) that match the query.
        """
        pass

    @abstractmethod
    async def delete_all(self) -> None:
        """
        Delete all records in the table.
        """
        pass


class DatabaseInterface(ABC):
    @abstractmethod
    async def open(self):
        """
        Open the database connection.
        """
        pass

    @abstractmethod
    async def close(self):
        """
        Close the database connection.
        """
        pass

    @abstractmethod
    def table(self, table_name: str) -> TableInterface:
        """
        Return a table handle for a given table or collection name.
        """
        pass

    @abstractmethod
    async def get_all_database(self) -> dict:
        """
        Retrieve all data from the entire database.
        """
        pass
