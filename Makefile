.PHONY: dev stop

dev:
	@echo "Starting backend and frontend..."
	@(cd backend && go run cmd/server/main.go & echo $$! > .backend.pid)
	@flutter run
	@make stop

stop:
	@if [ -f backend/.backend.pid ]; then \
		kill `cat backend/.backend.pid` && rm backend/.backend.pid; \
	fi
