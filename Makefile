.PHONY: clear_branch, setup, test_db

clear_branch: ## clear all branches in git except main and master
	@branches_to_delete=$$(git branch | grep -v "main\|master"); \
	for branch in $$branches_to_delete; do \
		echo "Deleting $$branch"; \
		git branch -d "$$branch" || echo "Failed to delete $$branch"; \
	done

setup: ## run setup file
	./bin/setup.sh


lint: ## Run the linter
	$(info Running linting...)
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 . --count --max-complexity=10 --max-line-length=127 --statistics

test_db: ## start the testing PostgreSQL user database
	docker run -d \
		--name test_users_db_container \
		-p 5432:5432 \
		-e POSTGRES_USER=testuser \
		-e POSTGRES_PASSWORD=testpassword \
		-e POSTGRES_DB=test_db \
		--health-cmd "pg_isready -U testuser -d test_db" \
		--health-interval 10s \
		--health-timeout 5s \
		--health-retries 5 \
		chainguard/postgres:latest


remove_test_db: ## stop the postgres test db container
	docker stop test_users_db_container
	docker rm test_users_db_container


